function TextToImage(Image)


%% Using:
% Image='1.jpg';
% ImageToText(Image)
%% This function converts a text file to an image

G= imread(Image);
 G= imresize(G,[100 100]);
 G= rgb2gray(G);
[R,C]=size(G);
%% Open a file for reading
fid = fopen('TextImage.txt');

% make sure the file is not empty
finfo = dir('TextImage.txt');
fsize = finfo.bytes;

if fsize > 0 

    % read the file
   
    while ~feof(fid)
        
        image1  = ...
          fscanf(fid, '%d')';
    end

end

save image1 image1
load image1 image1
% close the file
fclose(fid);


%% Oriente the image to be in R,C manner
%G1=uint8(reshape(image1,C,R));% for blurring
G1=int16(reshape(image1,R,C)); % for edge
%% Display the image:
figure, 
subplot(1,2,1),imshow(G),title('Image Prior to processing');
subplot(1,2,2),imshow(G1,[]),title('Image After processing');

end

