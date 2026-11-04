package com.nunutech40.flutter_liveness_sdk

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Size
import android.view.View
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetector
import com.google.mlkit.vision.face.FaceDetectorOptions
import io.flutter.plugin.platform.PlatformView
import java.io.File
import java.io.FileOutputStream
import java.util.UUID
import java.util.concurrent.Executors

/** Camera and ML Kit detection only. The Flutter application renders the UI. */
internal class LivenessCameraPlatformView(
    private val context: Context,
    private val sessionId: String,
    steps: List<String>,
    timeoutMs: Long,
    private val auditMode: Boolean,
    private val hostActivity: Activity?,
) : PlatformView, Application.ActivityLifecycleCallbacks, LifecycleOwner {
    private val lifecycleRegistry = LifecycleRegistry(this)
    override val lifecycle: Lifecycle get() = lifecycleRegistry
    private val engine = ChallengeEngine(steps)
    private val previewView = PreviewView(context).apply {
        // The default PERFORMANCE mode may create a SurfaceView that escapes
        // Flutter's platform-view bounds and draws over the app's UI.
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        scaleType = PreviewView.ScaleType.FILL_CENTER
    }
    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()
    private val evidence = mutableMapOf<String, String>()
    private var provider: ProcessCameraProvider? = null
    private var preview: Preview? = null
    private var analysis: ImageAnalysis? = null
    private var imageCapture: ImageCapture? = null
    private var detector: FaceDetector? = null
    private var terminal = false
    private var capturing = false
    private var lastGuidance: String? = null
    private val timeoutAction = Runnable { finishSession("timedOut", "timeout") }

    init {
        lifecycleRegistry.currentState = Lifecycle.State.RESUMED
        (context.applicationContext as Application).registerActivityLifecycleCallbacks(this)
        LivenessSessions.attachCancel(sessionId) { finishSession("cancelled") }
        mainHandler.postDelayed(timeoutAction, timeoutMs)
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            openCamera()
        } else {
            finishSession("failed", "camera_permission_denied")
        }
    }

    override fun getView(): View = previewView

    private fun openCamera() {
        val future = ProcessCameraProvider.getInstance(context)
        future.addListener({
            if (terminal) return@addListener
            try {
                val readyProvider = future.get()
                if (!readyProvider.hasCamera(CameraSelector.DEFAULT_FRONT_CAMERA)) {
                    finishSession("failed", "front_camera_unavailable")
                    return@addListener
                }
                provider = readyProvider
                bindCamera(readyProvider)
            } catch (_: Exception) {
                finishSession("failed", "camera_initialization_failed")
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun bindCamera(readyProvider: ProcessCameraProvider) {
        val lowEnd = (context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager).let { manager ->
            val info = android.app.ActivityManager.MemoryInfo()
            manager.getMemoryInfo(info)
            manager.isLowRamDevice || info.totalMem < 2L * 1024L * 1024L * 1024L
        }
        val options = FaceDetectorOptions.Builder()
            .setPerformanceMode(if (lowEnd) FaceDetectorOptions.PERFORMANCE_MODE_FAST else FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
            .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
            .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
            .enableTracking()
            .build()
        detector = FaceDetection.getClient(options)
        preview = Preview.Builder().build().also { it.setSurfaceProvider(previewView.surfaceProvider) }
        imageCapture = ImageCapture.Builder().setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY).build()
        val analysisBuilder = ImageAnalysis.Builder().setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
        if (lowEnd) analysisBuilder.setTargetResolution(Size(480, 640))
        analysis = analysisBuilder.build().also { it.setAnalyzer(executor) { proxy -> analyze(proxy) } }
        try {
            readyProvider.bindToLifecycle(this, CameraSelector.DEFAULT_FRONT_CAMERA, preview, analysis, imageCapture)
            emit(mapOf("type" to "ready", "step" to engine.currentStep, "completedCount" to 0))
        } catch (_: Exception) {
            finishSession("failed", "camera_bind_failed")
        }
    }

    private fun analyze(proxy: ImageProxy) {
        if (terminal || capturing) { proxy.close(); return }
        val image = proxy.image ?: run { proxy.close(); return }
        val input = InputImage.fromMediaImage(image, proxy.imageInfo.rotationDegrees)
        detector?.process(input)
            ?.addOnSuccessListener(ContextCompat.getMainExecutor(context)) { faces ->
                if (terminal || capturing) return@addOnSuccessListener
                when {
                    faces.isEmpty() -> { engine.resetTransient(); guide("no_face") }
                    faces.size > 1 -> { engine.resetTransient(); guide("multiple_faces") }
                    else -> {
                        val face = faces[0]
                        if (lastGuidance != null) {
                            lastGuidance = null
                            emit(mapOf("type" to "ready", "step" to engine.currentStep,
                                "completedCount" to engine.passedCount))
                        }
                        val update = engine.update(FaceSignals(
                            face.headEulerAngleY, face.smilingProbability,
                            face.leftEyeOpenProbability, face.rightEyeOpenProbability,
                            face.trackingId,
                        ))
                        if (update.passedStep != null) {
                            if (auditMode) saveEvidence(update.passedStep, proxy)
                            emit(mapOf("type" to "stepPassed", "step" to update.passedStep,
                                "completedCount" to engine.passedCount))
                        }
                        if (update.finalReady) captureFinal()
                    }
                }
            }
            ?.addOnFailureListener(ContextCompat.getMainExecutor(context)) {
                finishSession("failed", "face_detection_failed")
            }
            ?.addOnCompleteListener(ContextCompat.getMainExecutor(context)) { proxy.close() }
            ?: proxy.close()
    }

    private fun saveEvidence(step: String, proxy: ImageProxy) {
        try {
            val file = File(context.cacheDir, "liveness_${UUID.randomUUID()}_$step.jpg")
            val bitmap = proxy.toBitmap()
            val matrix = android.graphics.Matrix().apply { postRotate(proxy.imageInfo.rotationDegrees.toFloat()) }
            val oriented = android.graphics.Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            FileOutputStream(file).use { oriented.compress(android.graphics.Bitmap.CompressFormat.JPEG, 85, it) }
            if (oriented !== bitmap) oriented.recycle()
            bitmap.recycle()
            evidence[step] = file.absolutePath
        } catch (_: Exception) {
            finishSession("failed", "evidence_capture_failed")
        }
    }

    private fun captureFinal() {
        if (capturing || terminal) return
        capturing = true
        val capture = imageCapture ?: run { finishSession("failed", "camera_unavailable"); return }
        val file = File(context.cacheDir, "liveness_${UUID.randomUUID()}_selfie.jpg")
        val metadata = ImageCapture.Metadata().apply { isReversedHorizontal = true }
        val output = ImageCapture.OutputFileOptions.Builder(file).setMetadata(metadata).build()
        capture.takePicture(output, ContextCompat.getMainExecutor(context), object : ImageCapture.OnImageSavedCallback {
            override fun onImageSaved(result: ImageCapture.OutputFileResults) {
                finishSession("success", selfiePath = file.absolutePath)
            }
            override fun onError(exception: ImageCaptureException) {
                file.delete()
                finishSession("failed", "selfie_capture_failed")
            }
        })
    }

    private fun guide(code: String) {
        if (lastGuidance == code) return
        lastGuidance = code
        emit(mapOf("type" to "guidance", "code" to code,
            "step" to engine.currentStep, "completedCount" to engine.passedCount))
    }

    private fun emit(event: Map<String, Any?>) = LivenessSessions.emit(sessionId, event)

    private fun finishSession(status: String, errorCode: String? = null, selfiePath: String? = null) {
        if (terminal) return
        terminal = true
        mainHandler.removeCallbacks(timeoutAction)
        LivenessSessions.complete(sessionId, status, errorCode, selfiePath, evidence.toMap())
    }

    override fun dispose() {
        if (!terminal) finishSession("cancelled", "dismissed")
        (context.applicationContext as Application).unregisterActivityLifecycleCallbacks(this)
        val bound = listOfNotNull(preview, analysis, imageCapture)
        if (bound.isNotEmpty()) provider?.unbind(*bound.toTypedArray())
        detector?.close()
        executor.shutdown()
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
    }

    override fun onActivityResumed(activity: Activity) {
        if (activity === hostActivity && !terminal) lifecycleRegistry.currentState = Lifecycle.State.RESUMED
    }
    override fun onActivityPaused(activity: Activity) {
        if (activity === hostActivity && !terminal) lifecycleRegistry.currentState = Lifecycle.State.STARTED
    }
    override fun onActivityCreated(activity: Activity, state: Bundle?) = Unit
    override fun onActivityStarted(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, state: Bundle) = Unit
    override fun onActivityDestroyed(activity: Activity) = Unit
}
