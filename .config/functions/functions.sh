grelease() { git push origin "$(git_current_branch)" && git tag --annotate "$1" -m "$1" && git push origin "$1" }


fan_speed() {
local cpu_t=$(cat /sys/devices/platform/msi-ec/cpu/realtime_temperature)
local cpu_p=$(cat /sys/devices/platform/msi-ec/cpu/realtime_fan_speed)
local gpu_t=$(cat /sys/devices/platform/msi-ec/gpu/realtime_temperature)
local gpu_p=$(cat /sys/devices/platform/msi-ec/gpu/realtime_fan_speed)
local rpm=$(sensors | awk '/^fan[12]:/{printf "%s ",$2}')
printf "CPU %sC %s%% | GPU %sC %s%% | RPM %s\n" "$cpu_t" "$cpu_p" "$gpu_t" "$gpu_p" "$rpm"
}
