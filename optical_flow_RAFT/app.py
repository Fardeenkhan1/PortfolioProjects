import numpy as np
import torch
import torchvision.transforms.functional as F
from torchvision.io import read_video
from torchvision.models.optical_flow import raft_large
from torchvision.models.optical_flow import Raft_Large_Weights
from torchvision.utils import flow_to_image
import cv2
import glob
import gradio as gr
import shutil
import os

# If you can, run this example on a GPU, it will be a lot faster.
device = "cuda" if torch.cuda.is_available() else "cpu"
weights = Raft_Large_Weights.DEFAULT
transforms = weights.transforms()
model = raft_large(weights=Raft_Large_Weights.DEFAULT, progress=False).to(device)
model = model.eval()

def preprocess(img1_batch, img2_batch):
    img1_batch = F.resize(img1_batch, size=[520, 960], antialias=False)
    img2_batch = F.resize(img2_batch, size=[520, 960], antialias=False)
    return transforms(img1_batch, img2_batch)
from torchvision.models.optical_flow import raft_large

def clear_directory(folder):
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))


def predict(video_path):
    frames, _, _ = read_video(str(video_path), output_format="TCHW")

    # model.to(device)
    array = []
    for i, (img1, img2) in enumerate(zip(frames, frames[1:])):
        print(i)
        # if i > 0:
        #     break
        img1, img2 = preprocess(img1, img2)
        
        list_of_flows = model(img1.unsqueeze(0).to(device), img2.unsqueeze(0).to(device))
        predicted_flow = list_of_flows[-1][0]
        flow_img = flow_to_image(predicted_flow).to("cpu")
        array.append(flow_img.permute(1,2,0).numpy())

    image_path = "YOUR_INPUT_FILE_ADDRESS/tmp"
    for i, image in enumerate(array):
        cv2.imwrite(f"{image_path}/name_{i}.png", cv2.cvtColor(image, cv2.COLOR_RGB2BGR)) 

    img_array = []
    for filename in glob.glob(f"{image_path}/*.png"):
        img = cv2.imread(filename)
        height, width, layers = img.shape
        size = (width,height)
        img_array.append(img)
    outfile = 'YOUR_OUTPUT_FILE_ADDRESS/video.mp4'
    video_cap = cv2.VideoCapture(video_path)
    fps_video = video_cap.get(cv2.CAP_PROP_FPS)
    out = cv2.VideoWriter(outfile,cv2.VideoWriter_fourcc(*'XVID'), fps_video, size)

    for i in range(len(img_array)):
        out.write(img_array[i])
    out.release()

    clear_directory(image_path)

    return outfile

if __name__ == '__main__':
    gr_interface = gr.Interface(predict,
                                inputs = gr.Video(),
                                outputs = gr.Video())
    gr_interface.launch()