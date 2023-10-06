docker run -it \
--device /dev/dri \
-v ~/ai/apps:/apps \
-v ~/ai/deps:/deps \
-v ~/ai/huggingface:/root/.cache/huggingface \
itlackey/base-arc