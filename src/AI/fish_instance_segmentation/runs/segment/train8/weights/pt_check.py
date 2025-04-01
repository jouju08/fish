from ultralytics.nn.modules.head import Segment

_ = Segment(nc=2, nm=32, npr=64, ch=[64, 128, 256])
