import tensorflow as tf
import os
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"

# Load the SavedModel
model = tf.saved_model.load("segment_tf_model")

# Get inference function
infer = model.signatures["serving_default"]

# Rebuild model with output1 포함 (proto 추출용)
concrete_func = infer

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_concrete_functions([concrete_func])
converter.target_spec.supported_ops = [tf.lite.OpsSet.SELECT_TF_OPS]
tflite_model = converter.convert()

with open("segment_with_proto_fixed.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ proto 포함된 TFLite 모델 저장 완료")
