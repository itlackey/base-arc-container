import torch
import intel_extension_for_pytorch
print("XPU Available: " + str(torch.xpu.is_available()))