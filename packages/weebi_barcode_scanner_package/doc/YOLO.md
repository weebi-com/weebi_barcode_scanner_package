Model Version	Precision	Parameters	Size on Disk	Key Benefit
YOLOv8n (Standard)	FP32 (32-bit float)	~3.2 million	~12.1 MB	High precision
YOLOv8n (Quantized)	INT8 (8-bit integer)	~3.2 million	~3.2 MB	~4x smaller & faster


Model Family	Accuracy (COCO mAP)	Latency (ARM CPU)	Key Characteristic
YOLOv8n (Your current family)	~37%	~10-20ms	Excellent balance of speed and accuracy. The current state-of-the-art for this task.
EfficientDet-Lite0	~26%	~15-25ms	Designed by Google for edge. Generally trades accuracy for a slightly different architecture, but is often slower than the newest YOLO versions for a given accuracy level.
MobileNetV3-SSD	~22%	~10-20ms	An older, very fast architecture. Its accuracy is significantly lower and not competitive with modern YOLO for tasks that require detecting small or detailed objects.