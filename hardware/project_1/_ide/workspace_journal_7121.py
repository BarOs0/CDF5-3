# 2026-03-06T09:13:04.579782780
import vitis

client = vitis.create_client()
client.set_workspace(path="project_1")

client.delete_component(name="upload_img")

vitis.dispose()

