# 2026-03-05T18:15:05.721546472
import vitis

client = vitis.create_client()
client.set_workspace(path="project_1")

comp = client.create_app_component(name="upload_img",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_ps7_cortexa9_0")

vitis.dispose()

