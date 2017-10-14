function ImageToText(Image)

%% This function converts an image to a text file
%% Reading Image
G= imread(Image);
 G= imresize(G,[100 100]);
 G= rgb2gray(G);
[R,C]=size(G);
G= reshape(G,R*C,1);
%% Open a file for writing
fid= fopen('ImageText.txt','w');


% %% Print Image attributes (Row,Columns)
% fprintf(fid,'%d\r\n',length(G(:,1)));% rows
% fprintf(fid,'%d\r\n',length(G(1,:)));% columns

%% Print in Image Values
for i=1:length(G(:)), 
fprintf(fid,'%d\n',G(i));
end 
%% Close the file:
fclose(fid);

end

