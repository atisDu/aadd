F_VAR=AADD_STT
F_TITLE="Dictation on Mod+U (Whisper on the Intel NPU, ~800 MB download)"
F_PKGS="intel-npu-driver | - | - | Intel NPU userspace driver
python | python3-venv | python3 | Python venv
xdotool | xdotool | xdotool | types the text
pipewire | pipewire-bin | pipewire-utils | pw-record"
STT_MODEL=OpenVINO/whisper-large-v3-turbo-int8-ov
f_detect() { [ -e /dev/accel/accel0 ]; }
f_apply() {
	local data="$HOME/.local/share/stt"
	run python3 -m venv "$data/venv"
	run "$data/venv/bin/pip" install -q openvino-genai numpy huggingface_hub
	[ -d "$data/${STT_MODEL#*/}" ] ||
		run "$data/venv/bin/hf" download "$STT_MODEL" --local-dir "$data/${STT_MODEL#*/}"
	add_group render   # /dev/accel/accel0 is group render
}
