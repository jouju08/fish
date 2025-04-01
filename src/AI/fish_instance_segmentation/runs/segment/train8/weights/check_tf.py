import tensorflow as tf

# TFLite 모델 경로 설정
tflite_path = "/home/yun/fish_length/dataset/runs/segment/train8/weights/segment_tf_model/segment_v3_sim_float32.tflite"

# TFLite 인터프리터 초기화
interpreter = tf.lite.Interpreter(model_path=tflite_path)
interpreter.allocate_tensors()

# 출력 텐서 정보 확인
output_details = interpreter.get_output_details()

print("📦 TFLite Output Details:")
for i, out in enumerate(output_details):
    name = out['name']
    shape = out['shape']
    dtype = out['dtype']
    print(f"🔹 Output[{i}]: name={name}, shape={shape}, dtype={dtype}")

# proto 채널 수 확인
proto_shape = output_details[1]['shape']
nm = proto_shape[-1]  # NHWC 기준
print(f"\n✅ proto의 마지막 차원 (nm): {nm}")
