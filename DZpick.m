function varargout = DZpick(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,'gui_Singleton',gui_Singleton,'gui_OpeningFcn',@DZpick_OpeningFcn,'gui_OutputFcn',@DZpick_OutputFcn,'gui_LayoutFcn',[],'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function DZpick_OpeningFcn(hObject, eventdata, H, varargin)
H.output = hObject;
H.run = 0;
H.findspots = 0;
guidata(hObject, H);

function varargout = DZpick_OutputFcn(hObject, eventdata, H) 
circles = 0;
H.circles = circles;
guidata(hObject,H);
varargout{1} = H.output;

function selectfolder_Callback(hObject, eventdata, H)




folder_name = uigetdir;
files=dir([folder_name]); %map out the directory to that folder

for i = 1:size(files,1)
	filenames{i,1} = files(i).name;
end

for i = 1:size(filenames,1)
	if strcmp(filenames(i,1),'.') == 1
		filenames{i,1} = [];
	elseif strcmp(filenames(i,1),'..') == 1
		filenames{i,1} = [];
	end
end

filenames(all(cellfun('isempty',filenames),2),:) = [];

tmp1 = strfind(filenames(:,1), '.bmp');
tmp4 = strfind(filenames(:,1), '.Align');
tmp5 = strfind(filenames(:,1), '.scancsv');

for i = 1:length(filenames)
	if isempty(tmp1(~cellfun('isempty',tmp1(i,1)))) == 0
		if ispc == 1
			fullpathname1 = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname1 = char(strcat(folder_name, '/', filenames{i,1}));
		end
	end
end

H.originalImagetmp1 = imread(fullpathname1);

for i = 1:length(filenames)
	if isempty(tmp4(~cellfun('isempty',tmp4(i,1)))) == 0
		if ispc == 1
			fullpathname4 = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname4 = char(strcat(folder_name, '/', filenames{i,1}));
		end
	end
end

H.AlignFile = importdata(fullpathname4);

for i = 1:length(filenames)
	if isempty(tmp5(~cellfun('isempty',tmp5(i,1)))) == 0
		if ispc == 1
			fullpathname5 = char(strcat(folder_name, '\', filenames{i,1}));
		end
		if ismac == 1
			fullpathname5 = char(strcat(folder_name, '/', filenames{i,1}));
		end
	end
end

H.ScanFile = importdata(fullpathname5);

H.fullpathname5 = fullpathname5;

axes(H.image)
set(H.grayscale,'Value',1)
set(H.binary,'Value',0)
imshow(H.originalImagetmp1);

%[m,n]=size(H.originalImagetmp1);
%H.AR=m/n;
%H.pos = get(H.image,'Position');




%[file,path,indx] = uigetfile({'*.scancsv'},'Select a File');
%H.fullpathname_names = [path,file];
set(H.filepath, 'String', folder_name); %show path name
guidata(hObject, H);
run(hObject, eventdata, H)

function initialp_Callback(hObject, eventdata, H)

cla(H.hist,'reset'); 
cla(H.image,'reset'); 
cla(H.selected,'reset'); 
resolution = str2num(get(H.res,'String'));

w2 = waitbar(0,'Initial image processing, please wait...');

%originalImagetmp1 = H.originalImagetmp1;
%originalImage1_x = imresize(H.originalImagetmp1,[resolution NaN]);
%originalImage1_y = imresize(H.originalImagetmp1,[NaN resolution]);
%originalImage1 = imresize(H.originalImagetmp1,[resolution resolution]);
%scaling_factor_x = length(originalImagetmp1(:,1))/length(originalImage1_x(:,1));
%scaling_factor_y = length(originalImagetmp1(1,:))/length(originalImage1_y(1,:));





originalImagetmp1 = H.originalImagetmp1;
%originalImage1_x = imresize(H.originalImagetmp1,[resolution NaN]);
%originalImage1_y = imresize(H.originalImagetmp1,[NaN resolution]);
originalImage1 = imresize(H.originalImagetmp1,[resolution resolution]);
%scaling_factor_x = length(originalImagetmp1(:,1))/length(originalImage1_x(:,1));
%scaling_factor_y = length(originalImagetmp1(1,:))/length(originalImage1_y(1,:));




scaling_factor_rows = size(originalImagetmp1,1)/size(originalImage1,1)
scaling_factor_columns = size(originalImagetmp1,2)/size(originalImage1,2)





scaling_factor = numel(originalImagetmp1)/numel(originalImage1);
[rows, columns, numberOfColorChannels] = size(originalImage1);


%assignin('base','scaling_factor_rows',scaling_factor_rows)
%assignin('base','scaling_factor_columns',scaling_factor_columns)
%assignin('base','originalImagetmp1',originalImagetmp1)
%assignin('base','originalImage1',originalImage1)
%assignin('base','originalImage1_x',originalImage1_x)
%assignin('base','originalImage1_y',originalImage1_y)






if numberOfColorChannels > 1
	originalImage1 = rgb2gray(originalImage1);
end

thresh_lo = str2num(get(H.hist_lo,'String'));
thresh_hi = str2num(get(H.hist_hi,'String'));
binaryImage1 = originalImage1 > thresh_lo & originalImage1 < thresh_hi; 
binaryImage1 = imfill(binaryImage1, 'holes');
labeledImage1 = bwlabel(binaryImage1, 8);
coloredLabels1 = label2rgb(labeledImage1, 'hsv', 'k', 'shuffle'); 
[pixelCount, grayLevels] = imhist(originalImage1);




thresh_Area = str2num(get(H.area_thresh,'String'));

blobMeasurements1 = regionprops(labeledImage1, originalImage1, 'all');
numberOfBlobs = size(blobMeasurements1, 1);

boundaries1 = bwboundaries(binaryImage1);


count = 0;
for k = 1:numberOfBlobs         
	if blobMeasurements1(k).Area > thresh_Area && blobMeasurements1(k).MeanIntensity < 160 && blobMeasurements1(k).MaxIntensity - blobMeasurements1(k).MinIntensity < 180
		count = count + 1;
		blobMeasurements_All(count,:) = blobMeasurements1(k,:);
		blobArea(count,1) = blobMeasurements1(k).Area;	
		blobPerimeter(count,1) = blobMeasurements1(k).Perimeter;		
		blobCentroid1(count,1:2) = blobMeasurements1(k).Centroid;	
		blobBoundingBox1{count,1} = blobMeasurements1(k).BoundingBox;	
		blobFilled1{count,1} = blobMeasurements1(k).FilledImage;
		subImage1{count,1} = imcrop(originalImage1, blobMeasurements1(k).BoundingBox);
		subArray1{count,1} = blobMeasurements1(k).SubarrayIdx;
		blobBoundaries1(count,1) = boundaries1(k,1);
	end
	waitbar(k/numberOfBlobs,w2,'Filtering based on grain area, please wait...');
end
close(w2)

axes(H.hist)
bar(pixelCount);
xlim([0 grayLevels(end)]); % Scale x axis manually.
grid off;
hold on;
if get(H.ylog,'Value') == 1
	set(gca,'YScale','log')
end
maxYValue = ylim;
line([thresh_lo, thresh_lo], [maxYValue(1,1), maxYValue(1,2)], 'Color', 'r', 'LineWidth', 2);
line([thresh_hi, thresh_hi], [maxYValue(1,1), maxYValue(1,2)], 'Color', 'r', 'LineWidth', 2);
xlim([0 thresh_hi])



N1 = count;

if get(H.unknowns,'Value') == 1
	axes(H.image)
	hold on
	if get(H.grayscale,'Value') == 1
		set(H.binary,'Value',0)
		imshow(originalImage1); 
	elseif get(H.binary,'Value') == 1
		set(H.grayscale,'Value',0)
		imshow(binaryImage1); 
	end
	bb = [blobBoundingBox1{N1,1}];
	rec1 = rectangle('Position', [bb(1,1),bb(1,2),bb(1,3),bb(1,4)],'EdgeColor','r','LineWidth',3);
	thisCentroid = blobCentroid1(N1,:);
	cen1 = scatter(thisCentroid(1,1),thisCentroid(1,2),100,'filled');
end

for k = 1:N1
	thisBoundary = blobBoundaries1{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end

for k = 1:N1
	Names(k,1) = strcat({'Spot'}, {' '}, num2str(k));
end

if get(H.unknowns,'Value') == 1
	set(H.listbox1,'String', Names)
	set(H.listbox1,'Value', N1)
	axes(H.selected)
	hold on
	if get(H.grayscale,'Value') == 1
		set(H.binary,'Value',0)
		imshow(originalImage1); 
	elseif get(H.binary,'Value') == 1
		set(H.grayscale,'Value',0)
		imshow(binaryImage1); 
	end
	thisBoundary = blobBoundaries1{N1};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
	hold on
	axis([bb(1,1), bb(1,1)+bb(1,3), bb(1,2), bb(1,2)+bb(1,4)])	
	
	H.blobCentroid1 = blobCentroid1;
	H.blobFilled1 = blobFilled1;
	H.blobBoundingBox1 = blobBoundingBox1;
	H.subImage1 = subImage1;
	H.subArray1 = subArray1;
	H.blobMeasurements1 = blobMeasurements1;
	H.originalImage1 = originalImage1;
	H.binaryImage1 = binaryImage1;
	H.coloredLabels1 = coloredLabels1;
	H.labeledImage1 = labeledImage1;
	H.N1 = N1;
	H.blobBoundaries1 = blobBoundaries1;
	H.rec1 = rec1;
	H.cen1 = cen1;
	H.resolution = resolution;
	H.blobMeasurements_All = blobMeasurements_All;
	H.boundaries1 = boundaries1;
	H.scaling_factor = scaling_factor;
	%H.scaling_factor_x = scaling_factor_x;
	%H.scaling_factor_y = scaling_factor_y;
	H.scaling_factor_rows = scaling_factor_rows;
	H.scaling_factor_columns = scaling_factor_columns;
	
	
	
end

guidata(hObject,H);

function findspots_Callback(hObject, eventdata, H)
scaling_factor = H.scaling_factor;
labeledImage1 = H.labeledImage1;
originalImage1 = H.originalImage1;
binaryImage1 = H.binaryImage1;
blobBoundingBox1 = H.blobBoundingBox1;
blobFilled1 = H.blobFilled1;
N1 = H.N1;
blobMeasurements1 = H.blobMeasurements1;
coloredLabels1 = H.coloredLabels1;
rec1 = H.rec1;
blobBoundaries1 = H.blobBoundaries1;
blobMeasurements_All = H.blobMeasurements_All;

%scaling_factor_x = H.scaling_factor_x;
%scaling_factor_y = H.scaling_factor_y;

scaling_factor_rows = H.scaling_factor_rows;
scaling_factor_columns = H.scaling_factor_columns;

delete(rec1)

cla(H.image,'reset');
cla(H.selected,'reset'); 
axes(H.image)
axis image; 
hold on
if get(H.grayscale,'Value') == 1
	set(H.binary,'Value',0)
	imshow(originalImage1); 
elseif get(H.binary,'Value') == 1
	set(H.grayscale,'Value',0)
	imshow(binaryImage1); 
end




%{
if get(H.old_version, 'Value') == 1
	
	warning('off','all')
	w2 = waitbar(0,'Calculating maximum inscribed circles by Voronoi tessellation, please wait...');
	count1 = 0;
	for k = 1:length(blobBoundingBox1)
		BB = blobBoundingBox1{k,1};
		I = blobFilled1{k};
		[y,x] = find(I>0);
		contour = bwtraceboundary(logical(I), [y(1),x(1)], 'N', 8);
		[cx,cy,r] = find_inner_circle(contour(:,2),contour(:,1));
		if r > str2num(get(H.rad_thresh,'String'))
			count1 = count1 + 1;
			blobCenterx1(count1,1) = cx + BB(1,1) - 0.5;
			blobCentery1(count1,1) = cy + BB(1,2) - 0.5;
			blobRadius1(count1,1) = r;
			blobBoundingBox2{count1,1} = blobMeasurements_All(k).BoundingBox;
			blobBoundaries2(count1,1) = blobBoundaries1(k,1);
			blobCentroid1(count1,1:2) = blobMeasurements_All(k).Centroid;
			blobMeasurements_All2(count1,:) = blobMeasurements_All(k,:);
		end
		waitbar(k/length(blobBoundingBox1),w2,'Calculating maximum inscribed circles by Voronoi tessellation, please wait...');
	end
	close(w2)
	theta = [linspace(0,2*pi) 0];
	
	
	
	rsort = sort(blobRadius1);
	
	clear blobBoundingBox1 blobFilled1 blobBoundaries1 blobMeasurements_All
	blobBoundingBox1 = blobBoundingBox2;
	blobBoundaries1 = blobBoundaries2;
	blobMeasurements_All = blobMeasurements_All2;
	
	N1 = count1;
	
	for k = 1 : N1
		thisBoundary = blobBoundaries1{k};
		plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
	end
	
	bb = [blobBoundingBox1{N1,1}];
	rec1 = rectangle('Position', [bb(1,1),bb(1,2),bb(1,3),bb(1,4)],'EdgeColor','r','LineWidth',3);
	
	for k = 1:N1
		BB = blobBoundingBox1{k,1};
		plot(cos(theta)*blobRadius1(k,1)+blobCenterx1(k,1),sin(theta)*blobRadius1(k,1)+blobCentery1(k,1),'r', 'LineWidth', 1);
	end
	
	thisCentroid = blobCentroid1(N1,:);
	cen1 = scatter(thisCentroid(1,1),thisCentroid(1,2),100,'filled');
	
	
	for k = 1:N1
		Names(k,1) = strcat({'Spot'}, {' '}, num2str(k));
	end

	
	
	
	
	set(H.listbox1,'String', '')
	set(H.listbox1,'String', Names)
	set(H.listbox1,'Value', N1)
	%set(H.data_count,'String',N1)
	
	axes(H.selected)
	hold on
	if get(H.grayscale,'Value') == 1
		set(H.binary,'Value',0)
		set(H.colored,'Value',0)
		imshow(originalImage1);
	elseif get(H.binary,'Value') == 1
		set(H.grayscale,'Value',0)
		set(H.colored,'Value',0)
		imshow(binaryImage1);
	elseif get(H.colored,'Value') == 1
		set(H.grayscale,'Value',0)
		set(H.binary,'Value',0)
		imshow(coloredLabels1);
	end
	
	thisBoundary = blobBoundaries1{N1};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
	axis([bb(1,1), bb(1,1)+bb(1,3), bb(1,2), bb(1,2)+bb(1,4)])
	
	for k = 1:length(blobBoundingBox1)
		BB = blobBoundingBox1{k,1};
		plot(cos(theta)*blobRadius1(k,1)+blobCenterx1(k,1),sin(theta)*blobRadius1(k,1)+blobCentery1(k,1),'r', 'LineWidth', 2);
	end
	
	H.blobCenterx1 = blobCenterx1;
	H.blobCentery1 = blobCentery1;
	H.blobRadius1 = blobRadius1;
	H.blobCenterx1 = blobCenterx1;
	H.blobCentery1 = blobCentery1;
	H.blobBoundingBox1 = blobBoundingBox1;
	H.blobCentroid1 = blobCentroid1;
	H.blobMeasurements_All = blobMeasurements_All;
	H.blobBoundaries1 = blobBoundaries1;
	
	circles = 1;
	H.circles = circles;
	H.rec1 = rec1;
	H.cen1 = cen1;
	
	
	scaling_factor = numel(H.originalImagetmp1)/numel(H.originalImage1);
	for i = 1:str2num(get(H.unks,'String'))
		Area(i,1) = blobMeasurements_All(i).Area*scaling_factor/3.5;
	end

	
	
end

%}









%783 BC-09

%if get(H.old_version, 'Value') == 0

warning('off','all')
w2 = waitbar(0,'Calculating maximum inscribed circles by Voronoi tessellation, please wait...');
count1 = 0;
for k = 1:length(blobBoundingBox1)
	BB = blobBoundingBox1{k,1};
	I = blobFilled1{k};
	[y,x] = find(I>0);
	contour = bwtraceboundary(logical(I), [y(1),x(1)], 'N', 8);
	[cx,cy,r] = find_inner_circle(contour(:,2),contour(:,1));
	if get(H.rad_check,'Value') == 1
		
		if get(H.old_version, 'Value') == 1
			if r > str2num(get(H.rad_thresh,'String'))
				count1 = count1 + 1;
				blobCenterx2(count1,1) = cx + BB(1,1) - 0.5;
				blobCentery2(count1,1) = cy + BB(1,2) - 0.5;
				blobRadius2(count1,1) = r;
				blobBoundingBox2{count1,1} = blobMeasurements_All(k).BoundingBox;
				blobBoundaries2(count1,1) = blobBoundaries1(k,1);
				blobCentroid2(count1,1:2) = blobMeasurements_All(k).Centroid;
				blobMeasurements_All2(count1,:) = blobMeasurements_All(k,:);
			end
			
		end
		
		if get(H.old_version, 'Value') == 0
			if 2.*r./scaling_factor/5 > str2num(get(H.rad_thresh,'String'))
				count1 = count1 + 1;
				blobCenterx2(count1,1) = cx + BB(1,1) - 0.5;
				blobCentery2(count1,1) = cy + BB(1,2) - 0.5;
				blobRadius2(count1,1) = r;
				blobBoundingBox2{count1,1} = blobMeasurements_All(k).BoundingBox;
				blobBoundaries2(count1,1) = blobBoundaries1(k,1);
				blobCentroid2(count1,1:2) = blobMeasurements_All(k).Centroid;
				blobMeasurements_All2(count1,:) = blobMeasurements_All(k,:);
			end
		end
		
	end
	if get(H.rad_check,'Value') == 0
		count1 = count1 + 1;
		blobCenterx2(count1,1) = cx + BB(1,1) - 0.5;
		blobCentery2(count1,1) = cy + BB(1,2) - 0.5;
		blobRadius2(count1,1) = r;
		blobBoundingBox2{count1,1} = blobMeasurements_All(k).BoundingBox;
		blobBoundaries2(count1,1) = blobBoundaries1(k,1);
		blobCentroid2(count1,1:2) = blobMeasurements_All(k).Centroid;
		blobMeasurements_All2(count1,:) = blobMeasurements_All(k,:);
	end
	waitbar(k/length(blobBoundingBox1),w2,'Calculating maximum inscribed circles by Voronoi tessellation, please wait...');
end
close(w2)
theta = [linspace(0,2*pi) 0];





%clear blobBoundingBox1 blobFilled1 blobBoundaries1 blobMeasurements_All
%blobBoundingBox1 = blobBoundingBox2;
%blobBoundaries1 = blobBoundaries2;
%blobMeasurements_All = blobMeasurements_All2;

N1 = count1;

for k = 1 : N1
	thisBoundary = blobBoundaries2{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end

bb = [blobBoundingBox2{N1,1}];
rec1 = rectangle('Position', [bb(1,1),bb(1,2),bb(1,3),bb(1,4)],'EdgeColor','r','LineWidth',3);

for k = 1:N1
	BB = blobBoundingBox2{k,1};
	plot(cos(theta)*blobRadius2(k,1)+blobCenterx2(k,1),sin(theta)*blobRadius2(k,1)+blobCentery2(k,1),'r', 'LineWidth', 1);
end

thisCentroid = blobCentroid2(N1,:);
cen1 = scatter(thisCentroid(1,1),thisCentroid(1,2),100,'filled');

for k = 1:N1
	Names(k,1) = strcat({'Spot'}, {' '}, num2str(k));
end


set(H.listbox1,'String', '')
set(H.listbox1,'String', Names)
set(H.listbox1,'Value', N1)
%set(H.data_count,'String',N1)


H.Names_out = Names;

axes(H.selected)
hold on
if get(H.grayscale,'Value') == 1
	set(H.binary,'Value',0)
	imshow(originalImage1);
elseif get(H.binary,'Value') == 1
	set(H.grayscale,'Value',0)
	imshow(binaryImage1);
end

thisBoundary = blobBoundaries2{N1};
plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
axis([bb(1,1), bb(1,1)+bb(1,3), bb(1,2), bb(1,2)+bb(1,4)])

for k = 1:length(blobBoundingBox2)
	BB = blobBoundingBox2{k,1};
	plot(cos(theta)*blobRadius2(k,1)+blobCenterx2(k,1),sin(theta)*blobRadius2(k,1)+blobCentery2(k,1),'r', 'LineWidth', 2);
end


H.blobCenterx2 = blobCenterx2;
H.blobCentery2 = blobCentery2;
H.blobRadius2 = blobRadius2;
H.blobCenterx2 = blobCenterx2;
H.blobCentery2 = blobCentery2;
H.blobBoundingBox2 = blobBoundingBox2;
H.blobCentroid2 = blobCentroid2;
H.blobMeasurements_All = blobMeasurements_All;
H.blobBoundaries2 = blobBoundaries2;

circles = 1;
H.circles = circles;
H.rec1 = rec1;
H.cen1 = cen1;


diamet = 2.*blobRadius2./scaling_factor/5;

H.diamet = diamet;

set(H.diameter1,'String',round(diamet(N1,1),1))



resolution = H.resolution;
%blobCenterx1 = H.blobCenterx1;
%blobCentery1 = H.blobCentery1;
blobMeasurements_All = H.blobMeasurements_All;

ScanFile  = H.ScanFile;

c = char(H.AlignFile{5,1});
c1 = strfind(char(H.AlignFile{5,1}),'<Center>');
c2 = strfind(char(H.AlignFile{5,1}),'</Center>');
Aligntmp1 = regexp(c(1,c1+8:c2-1), ',', 'split');
AlignCenter(1,1) = str2num(cell2mat(Aligntmp1(1,1)));
AlignCenter(1,2) = str2num(cell2mat(Aligntmp1(1,2)));

s = char(H.AlignFile{6,1});
s1 = strfind(char(H.AlignFile{6,1}),'<Size>');
s2 = strfind(char(H.AlignFile{6,1}),'</Size>');
Aligntmp2 = regexp(s(1,s1+6:s2-1), ',', 'split');
AlignSize(1,1) = str2num(cell2mat(Aligntmp2(1,1)));
AlignSize(1,2) = str2num(cell2mat(Aligntmp2(1,2)));

xlo = AlignCenter(1,1) - AlignSize(1,1)/2;
xhi = AlignCenter(1,1) + AlignSize(1,1)/2;
ylo = AlignCenter(1,2) - AlignSize(1,2)/2;
yhi = AlignCenter(1,2) + AlignSize(1,2)/2;

xdiff = xhi - xlo;
ydiff = yhi - ylo;
xr = xdiff/(resolution-1);
yr = ydiff/(resolution-1);
xF = xlo:xr:xhi;
yF = ylo:yr:yhi;
[X,Y] = meshgrid(xF,yF);

for k = 1:length(blobCenterx2)
	vtmpx = val2ind([1:1:resolution],blobCenterx2(k,1));
	vtmpy = val2ind([1:1:resolution],blobCentery2(k,1));
	blobCenterx_idx(k,1) = vtmpx(1,1);
	blobCentery_idx(k,1) = vtmpy(1,1);
	CenterUnknowns_x(k,1) = X(1,blobCenterx_idx(k,1));
	CenterUnknowns_y(k,1) = Y(blobCentery_idx(k,1),1);
end

ScanCellH = H.ScanFile(1,1);
ScanCell = H.ScanFile(2,1);
ScanCell_all = char(ScanCell);
sc1 = strfind(ScanCell_all,'1,0,1,"');
sc2 = strfind(ScanCell_all,'","Dosage=');
ScanCell_coords = regexp(ScanCell_all(1,sc1+7:sc2-1), ',', 'split');

OUT_unknowns(1,1) = H.ScanFile(1,1);

for k = 2:H.n+1
	OUT_unknowns(k,1) = strrep(ScanCell, {'Spot 1'}, strcat({'Spot'}, {' '}, num2str(k-1)));
	%OUT_morphology(k,1) = strcat({'Spot'}, {' '}, num2str(k));
end

for k = 2:H.n+1
	OUT_unknowns(k,1) = strrep(OUT_unknowns(k,1), ScanCell_coords(1,1), strcat(num2str(round(CenterUnknowns_x(k-1,1),0)),{'.00'}));
end

for k = 2:H.n+1
	OUT_unknowns(k,1) = strrep(OUT_unknowns(k,1), ScanCell_coords(1,2), strcat(num2str(round(CenterUnknowns_y(k-1,1),0)),{'.00'}));
end

Names = [OUT_unknowns(2:end);ScanFile(2:end,1)];
%IN = Names;

H.Names = Names;
%H.IN = IN;

%for i = 1:length(blobMeasurements_All2)
%	Area(i,1) = blobMeasurements_All2(i).Area*scaling_factor/3.5;
%end




H.findspots = 1;
guidata(hObject,H);

run(hObject, eventdata, H)




%assignin('base','blobMeasurements_All2',blobMeasurements_All2)

%end






%assignin('base','Area',Area)

%{
FF = figure;
hold on
for k = 1 : N1
	thisBoundary = blobBoundaries2{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
scatter(blobCenterx2(1:length(OUT_unknowns)-1,1), blobCentery2(1:length(OUT_unknowns)-1,1), '.')

for k = 1 : length(OUT_unknowns)-1
	text(blobCenterx2(k,1),blobCentery2(k,1),num2str(k))
end


[file2,path2] = uiputfile('*.eps','Save file');
print(FF,'-depsc','-painters',[path2 file2]);
%epsclean([path2 file2]); 
%}



ss = char(H.AlignFile{6,1});
ss1 = strfind(char(H.AlignFile{6,1}),'<Size>');
ss2 = strfind(char(H.AlignFile{6,1}),'</Size>');
SizeBMP_tmp = regexp(ss(1,ss1+6:ss2-1), ',', 'split');

SizeBMP_columns = cell2mat(SizeBMP_tmp(1,1));
SizeBMP_rows = cell2mat(SizeBMP_tmp(1,2));





SizeBMP_t1 = cell2mat(SizeBMP_tmp(1,1));
SizeBMP_t2 = cell2mat(SizeBMP_tmp(1,2));
SizeBMP(1,1) = str2num(SizeBMP_t1);
SizeBMP(1,2) = str2num(SizeBMP_t2);

SizeBMP(1,1)/size(H.originalImagetmp1,2)
SizeBMP(1,2)/size(H.originalImagetmp1,1)
fact = (SizeBMP(1,1)/size(H.originalImagetmp1,2) + SizeBMP(1,2)/size(H.originalImagetmp1,1)) / 2


for k = 1:length(OUT_unknowns)-1
	[rows cols] = size(blobMeasurements_All2(k,1).FilledImage);
	%j3 = imresize(H.originalImage1, [size(H.originalImage1,1)*scaling_factor_rows size(H.originalImage1,2)*scaling_factor_columns]);
	j3 = imresize(blobMeasurements_All2(k).FilledImage, [rows*scaling_factor_rows cols*scaling_factor_columns]);
	labeledImage3 = bwlabel(j3, 8);
	j3_props = regionprops(labeledImage3, j3, 'All');
	[maxx idxx] = max([j3_props.Area]);
	
	blobMeasurements_OUT(k,:) = j3_props(idxx);
	
	Area_Scaled(k,1) = sum([blobMeasurements_OUT(k,:).Area])*(fact^2); 

end



assignin('base','blobMeasurements_OUT',blobMeasurements_OUT)
assignin('base','Area_Scaled',Area_Scaled)



H.Area_Scaled = Area_Scaled;
H.blobMeasurements_OUT = blobMeasurements_OUT;



%{
size(H.originalImagetmp1)
size(H.originalImage1)
fff = imresize(blobMeasurements_All2(k).FilledImage, [rows columns])



for k = 1:length(OUT_unknowns)-1
	[xxx yyy] = size(blobMeasurements_All2(k,1).FilledImage);
	j2 = imresize(blobMeasurements_All2(k).FilledImage, [xxx*scaling_factor_x yyy*scaling_factor_y]);
	labeledImage3 = bwlabel(j2, 8);
	j2_area = regionprops(labeledImage3, j2, 'Area');
	Area_Scaled(k,1) = j2_area(1).Area*fact; 
	%figure
	%imshow(j2)
	clear xxx yyy j2 j2_area
end
%}




%{

% ROUNDNESS

% weighting factor for Diepenbroek
for i = 1:24
	c1(i,1) = .56*exp(0.2*i);
end
c1 = nonzeros(c1);

for i = 2:24
	c2(i,1) = .56*exp(0.2*i);
end
c2 = nonzeros(c2);

for i = 3:24
	c3(i,1) = .56*exp(0.2*i);
end
	c3 = nonzeros(c3);

for i = 3:100
	c4(i,1) = .56*exp(0.2*i);
end
c4 = nonzeros(c4);

for files=1:n
	C = blobMeasurements_OUT(files).Image;
	C = double(C);
	
	
	C = imresize(C,[2^14 NaN]);
	%figure
	%imshow(C) %show binary image with holes filled
	files
	[Label,Total]=bwlabel(C,4); %find all the ones and how many there are
	num=1; %because ones are the grain shape
	[row, col] = find(Label==num); %find the row idx of ones in each in each column and which columns they correspond to

	% find bounding box
	sx=min(col)-0.5;
	sy=min(row)-0.5;
	breadth=max(col)-min(col)+1;
	len=max(row)-min(row)+1;
	BBox=[sx sy breadth len];
	x=zeros([1 5]);
	y=zeros([1 5]);
	x(:)=BBox(1);
	y(:)=BBox(2);
	x(2:3)=BBox(1)+BBox(3);
	y(3:4)=BBox(2)+BBox(4);
	%figure, imshow(C), hold on, plot(x,y), hold off; %plot binary image with bounding box

	% find centroid
	Obj_area=numel(row);
	X=mean(col);
	Y=mean(row);
	Centroid=[X Y];
	BW=bwboundaries(Label==num);
	%figure, imshow(C), hold on, plot(x,y), scatter(X,Y, 100, 'filled'), hold off; %plot binary image with bounding box and centroid

	% find perimeter
	c=cell2mat(BW(1));
	Perimeter=0;
	for i=1:size(c,1)-1
	Perimeter=Perimeter+sqrt((c(i,1)-c(i+1,1)).^2+(c(i,2)-c(i+1,2)).^2);
	end

	pixels_area = sum(C(:));
	pixels_perimeter = length(c(:,2));

	Circularity=(4*Obj_area*pi)/(Perimeter.^2);

	stats = regionprops(C, 'MajorAxisLength','MinorAxisLength');
	stats2 = struct2cell(stats);
	axis_Major = cell2mat(stats2(1,1));
	axis_Minor = cell2mat(stats2(2,1));
	AR = axis_Major/axis_Minor;

	C_AR = 0.826261 + 0.337479*AR - 0.335455*AR.^2 + 0.103642*AR.^3 - 0.0155562*AR.^4 + 0.00114582*AR.^5 - 0.0000330834*AR.^6;

	R = Circularity + (0.913 - C_AR);
	R_out(files,1) = R;

	cir_x = c(:,2);
	cir_y = -c(:,1);
	cent_x = Centroid(:,1);
	cent_y = -Centroid(:,2);

	x_centered = cir_x-cent_x;
	y_centered = cir_y-cent_y;

	[theta, rho] = cart2pol(x_centered,y_centered);

	theta_deg = (theta.*180)./pi;

	for i = 1:length(theta_deg)
		if theta_deg(i,1) < 0
			theta_deg(i,1) = theta_deg(i,1)+360;
		else
			theta_deg(i,1) = theta_deg(i,1);
		end
	end

	theta_rho = [theta_deg,rho];
	theta_rho_sort = sortrows(theta_rho, 1);

	theta_sort = theta_rho_sort(:,1);
	rho_sort = theta_rho_sort(:,2);

	for i = 2:length(theta_sort)
		if theta_sort(i, 1) <= theta_sort(i-1, 1)
			theta_rho_sort(i, 1) = theta_rho_sort(i, 1)+.00000000001;
			theta_sort(i, 1) = theta_sort(i, 1)+.00000000001;
		end
	end

	theta_interp = 0:0.3515625:360-0.3515625;
	%theta_interp = 0:1:359;
	
	
	theta_rho_sort = theta_rho_sort + rand(size(theta_rho_sort))*.000000001;
	
	rho_interp = interp1(theta_rho_sort(:,1), theta_rho_sort(:,2), theta_interp);

	ind1=find(~isnan(rho_interp),1,'first');
	ind2=find(~isnan(rho_interp),1,'last');
	rho_interp(1:ind1-1)=rho_interp(ind1);
	rho_interp(ind2+1:end)=rho_interp(ind2);

	N=length(y);

	%%%%%     Fourier analysis for Deipenbroek     %%%%%
	F = fft(rho_interp);

	A = 2*real(F)/N ;
	A(1)= A(1)/2 ;
	B =-2*imag(F)/N ;
	A0 = A(1);

	Anorm = abs(A)/A0;
	Bnorm = abs(B)/A0;
	ABnorm = Anorm+Bnorm;

	Anorm_out(files,1) = sum(Anorm(1:25));
	Bnorm_out(files,1) = sum(Bnorm(1:25));
	ABnorm_out(files, :) = ABnorm(1:25);

	%sum first 24 harmonics
	%P_out(files,1) = exp(-1.25*sum(ABnorm(2:25)));

	% scale summed harmonics
	P2_tmp = transpose(c1).*ABnorm(2:25);
	P2sum = sum(P2_tmp);
	P2_out(files,1) = exp(-1.25*P2sum);
	P2_out_noscale(files,1) = P2sum;

	%P2_tmp2 = transpose(c2).*ABnorm(3:25);
	%P2sum2 = sum(P2_tmp2);
	%P2_out2(files,1) = exp(-1.25*P2sum2);

	% scaled and harmnic 2 completely removed
	P2_tmp3 = transpose(c1(3:24)).*ABnorm(4:25);
	P2_tmp4 = transpose(c1(1,1)).*ABnorm(1,2);
	P2sum3 = sum(P2_tmp3)+P2_tmp4;
	P2_out3(files,1) = exp(-1.25*P2sum3);
	P2_out3_noscale(files,1) = P2sum3;

	% scaled and harmonics 3-100 summed
	P2_tmp4 = transpose(c4).*ABnorm(4:101);
	P2sum4 = sum(P2_tmp3);
	P2_out4(files,1) = exp(-1.25*P2sum4);
	P2_out4_noscale(files,1) = P2sum4;

	% remove second ellipsoid from correlation with second harmonic
	harmonic2 = ABnorm(1,3);
	half_axes = 1 - 1.74*harmonic2 + 0.86*(harmonic2*harmonic2);
	half_axes_out(files,1) = half_axes;

	P2_tmp = transpose(c1).*ABnorm(2:25);
	P2sum = sum(P2_tmp);
	RESULTS(files,1) = exp(-1.25*P2sum);
	RESULTS_noscale(files,1) = P2sum;

	%P3_tmp = transpose(c1).*(ABnorm(2:25) - half_axes);
	%P3sum = sum(P3_tmp);
	%P3_out(files,1) = exp(-1.25*P3sum);

	clearvars -except RESULTS RESULTS_noscale name files theta_interp Anorm_out Bnorm_out A B Anorm Bnorm ABnorm ABnorm_out c1 c2 c3 P2_out P3_out half_axes_out P3_tmp actual R R_out ...
    P2_out3 c4 P2_out4 blobMeasurements_All n P2_out_noscale P2_out3_noscale P2_out4_noscale blobMeasurements_OUT Area_Scaled
end

%}


















guidata(hObject, H);



d=6










function run(hObject, eventdata, H)

%H.findspots = 1



FC1 = get(H.newprimary,'String'); %Primary
R33 = get(H.newsecondary,'String'); %Secondary
Sample = get(H.newname,'String');


if H.findspots == 0

Names = importdata(H.fullpathname5);
IN = Names;
Names = Names(2:end,1);
set(H.listbox3,'String',IN)

if length(IN)-1 == 22
	set(H.num_unknowns, 'Value', 1)
elseif length(IN)-1 == 34
	set(H.num_unknowns, 'Value', 2)
elseif length(IN)-1 == 38
	set(H.num_unknowns, 'Value', 3)
elseif length(IN)-1 == 46
	set(H.num_unknowns, 'Value', 4)
elseif length(IN)-1 == 58
	set(H.num_unknowns, 'Value', 5)	
elseif length(IN)-1 == 70
	set(H.num_unknowns, 'Value', 6)	
elseif length(IN)-1 == 82
	set(H.num_unknowns, 'Value', 7)	
elseif length(IN)-1 == 94
	set(H.num_unknowns, 'Value', 8)	
elseif length(IN)-1 == 106
	set(H.num_unknowns, 'Value', 9)	
elseif length(IN)-1 == 118
	set(H.num_unknowns, 'Value', 10)	
elseif length(IN)-1 == 130
	set(H.num_unknowns, 'Value', 11)	
elseif length(IN)-1 == 144
	set(H.num_unknowns, 'Value', 12)	
elseif length(IN)-1 == 154
	set(H.num_unknowns, 'Value', 13)	
elseif length(IN)-1 == 166
	set(H.num_unknowns, 'Value', 14)	
elseif length(IN)-1 == 178
	set(H.num_unknowns, 'Value', 15)	
elseif length(IN)-1 == 190
	set(H.num_unknowns, 'Value', 16)	
elseif length(IN)-1 == 202
	set(H.num_unknowns, 'Value', 17)	
elseif length(IN)-1 == 214
	set(H.num_unknowns, 'Value', 18)	
elseif length(IN)-1 == 226
	set(H.num_unknowns, 'Value', 19)	
elseif length(IN)-1 == 238
	set(H.num_unknowns, 'Value', 20)
elseif length(IN)-1 == 250
	set(H.num_unknowns, 'Value', 21)	
elseif length(IN)-1 == 262
	set(H.num_unknowns, 'Value', 22)	
elseif length(IN)-1 == 274
	set(H.num_unknowns, 'Value', 23)	
elseif length(IN)-1 == 286
	set(H.num_unknowns, 'Value', 24)	
elseif length(IN)-1 == 298
	set(H.num_unknowns, 'Value', 25)	
end

if get(H.num_unknowns, 'Value') == 1
	n = 50;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
elseif get(H.num_unknowns, 'Value') == 2
	n = 100;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)	
elseif get(H.num_unknowns, 'Value') == 3
	n = 120;
	n_p = 34;
	n_s = 4;
	n_all = 158;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
end
if get(H.num_unknowns, 'Value') > 3
	n = (get(H.num_unknowns,'Value')-1)*50;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
end

set(H.num_unknowns,'Enable', 'off')

H.n = n;
H.IN = IN;
guidata(hObject,H);

end





if H.findspots == 1

	Names = H.Names;
	IN = H.IN;
	n = H.n;
	
	OUT4_cleaning_shots(1,1) = IN(1,1);
	OUT4_cleaning_shots(2:length(Names)+1,1) = Names;
	
if get(H.num_unknowns, 'Value') == 1 || get(H.num_unknowns, 'Value') == 2 || get(H.num_unknowns, 'Value') > 3

	for i = n+1:n+n/5+10
		S = strcat({'Spot'}, {' '}, num2str(i-n));
		Names(i,1) = strrep(Names(i,1), S, FC1);
	end

	for i = n+n/5+11:n+n/5+10+n/25 
		S = strcat({'Spot'}, {' '}, num2str(i-n));
		Names(i,1) = strrep(Names(i,1), S, R33);
	end
	
	for i = 1:n 
		S = strcat({'Spot'}, {' '}, num2str(i));	
		Names(i,1) = strrep(Names(i,1), S, strcat(Sample, {' '}, num2str(i)));
	end
	
	Unknowns = Names(1:n); % 1:300 for 300
	FCs_tmp = Names(n+1:n+n/5+10); % 301:370 for 300
	R33s_tmp = Names(n+n/5+11:n+n/5+10+n/25); % 371:382 for 300
	
	[r c] = size(FCs_tmp);
	shuffledRow = randperm(r);
	FCs = FCs_tmp(shuffledRow, :);
	
	[r2 c2] = size(R33s_tmp);
	shuffledRow2 = randperm(r2);
	R33s = R33s_tmp(shuffledRow2, :);

	for i = 1:n/5 %60 for 300
		OUT(i*6+5,1) = FCs(i+5,1);
		OUT(i*6:i*6+4,1) = Unknowns(((i-1)*5)+1:i*5,1);
	end

	for i = 1:n/50 %6 for 300
		OUT3(((i-1)*62)+8:((i-1)*62)+67,1) = OUT(((i-1)*60)+6:((i-1)*60)+65);
		OUT3(((i-1)*62)+6:((i-1)*62)+7) = R33s(i*2-1:i*2);
	end

	OUT3(1:5,1) = FCs(1:5,1);
	OUT3(length(OUT3)+1:length(OUT3)+5) = FCs(length(FCs)-4:length(FCs),1);

end

if get(H.num_unknowns, 'Value') == 3

	for i = 121:154
		S = strcat({'Spot'}, {' '}, num2str(i-n));
		Names(i,1) = strrep(Names(i,1), S, FC1);
	end

	for i = 155:158
		S = strcat({'Spot'}, {' '}, num2str(i-n));
		Names(i,1) = strrep(Names(i,1), S, R33);
	end
	
	for i = 1:n 
		S = strcat({'Spot'}, {' '}, num2str(i));
		Names(i,1) = strrep(Names(i,1), S, strcat(Sample, {' '}, num2str(i)));
	end
	
	Unknowns = Names(1:n); 
	FCs = Names(121:154); 
	R33s = Names(155:158);
	
	Unknowns = Names(1:n); % 1:300 for 300
	FCs_tmp = Names(n+1:n+n/5+10); % 301:370 for 300
	R33s_tmp = Names(n+n/5+11:n+n/5+10+n/25); % 371:382 for 300
	
	[r c] = size(FCs_tmp);
	shuffledRow = randperm(r);
	FCs = FCs_tmp(shuffledRow, :);
	
	[r2 c2] = size(R33s_tmp);
	shuffledRow2 = randperm(r2);
	R33s = R33s_tmp(shuffledRow2, :);
	
	for i = 1:n/5 
		OUT(i*6+5,1) = FCs(i+5,1);
		OUT(i*6:i*6+4,1) = Unknowns(((i-1)*5)+1:i*5,1);
	end	
	
	for i = 1:2 
		OUT3(((i-1)*62)+8:((i-1)*62)+67,1) = OUT(((i-1)*60)+6:((i-1)*60)+65);
		OUT3(((i-1)*62)+6:((i-1)*62)+7) = R33s(i*2-1:i*2);
	end
	
	OUT3(1:5,1) = FCs(1:5,1);
	OUT3(130:153,1) = OUT(126:149,1);
	OUT3(length(OUT3)+1:length(OUT3)+5) = FCs(length(FCs)-4:length(FCs),1);

end

OUT4(2:length(OUT3(:,1))+1,1) = OUT3;
OUT4(1,1) = IN(1,1);

set(H.listbox4,'String',OUT4)

H.OUT4_cleaning_shots = OUT4_cleaning_shots;
H.OUT4 = OUT4;
H.run = 1;
guidata(hObject, H);	
	
	
	
	
end

function export_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.scancsv','Save file');
dlmcell([path,file],H.OUT4)

function save_geom_Callback(hObject, eventdata, H)
Area_Scaled = H.Area_Scaled;
blobMeasurements_OUT = H.blobMeasurements_OUT;
Names_out = H.Names_out;




geom_out = [Names_out(1:length(Area_Scaled),1), num2cell(Area_Scaled)];


T = struct2table(blobMeasurements_OUT);


geom_out(1:length(Area_Scaled),3:37) = table2cell(T);


geom_out2(2:length(Area_Scaled)+1,:) = geom_out;

geom_out2(1,1) = {'Name'};

geom_out2(1,2) = {'Area_Scaled (um^2)'};

geom_out2(1,3:end) = T.Properties.VariableNames;

geom_out2(:,6) = [];
geom_out2(:,10:11) = [];
geom_out2(:,12:13) = [];
geom_out2(:,14) = [];
geom_out2(:,4:5) = [];
geom_out2(:,15:16) = [];
geom_out2(:,17:18) = [];
geom_out2(:,17:19) = [];
geom_out2(:,19) = [];
geom_out2(:,21) = [];
geom_out2(:,11) = [];

[file,path] = uiputfile('*.xls','Save file');
writetable(table(geom_out2),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);


d=0








function unks_Callback(hObject, eventdata, H)
function prims_Callback(hObject, eventdata, H)
function secs_Callback(hObject, eventdata, H)
function res_Callback(hObject, eventdata, H)
function area_thresh_Callback(hObject, eventdata, H)
function ylog_Callback(hObject, eventdata, H)
function hist_lo_Callback(hObject, eventdata, H)
function hist_hi_Callback(hObject, eventdata, H)
function unknowns_Callback(hObject, eventdata, H)
set(H.unknowns,'Value',1)
set(H.primaries,'Value',0)
set(H.secondaries,'Value',0)
function primaries_Callback(hObject, eventdata, H)
set(H.unknowns,'Value',0)
set(H.primaries,'Value',1)
set(H.secondaries,'Value',0)
function secondaries_Callback(hObject, eventdata, H)
set(H.unknowns,'Value',0)
set(H.primaries,'Value',0)
set(H.secondaries,'Value',1)
function grayscale_Callback(hObject, eventdata, H)
originalImage1 = H.originalImage1;
blobBoundingBox1 = H.blobBoundingBox1;
N1 = H.N1;
blobCentroid1 = H.blobCentroid1;

set(H.binary,'Value',0)
set(H.grayscale,'Value',1)

if get(H.unknowns,'Value') == 1
	axes(H.image)
	hold on
	if get(H.grayscale,'Value') == 1
		set(H.binary,'Value',0)
		imshow(originalImage1); 
	elseif get(H.binary,'Value') == 1
		set(H.grayscale,'Value',0)
		imshow(binaryImage1); 
	end
	bb = [blobBoundingBox1{N1,1}];
	rec1 = rectangle('Position', [bb(1,1),bb(1,2),bb(1,3),bb(1,4)],'EdgeColor','r','LineWidth',3);
	thisCentroid = blobCentroid1(N1,:);
	cen1 = scatter(thisCentroid(1,1),thisCentroid(1,2),100,'filled');
end

set(H.image, 'DataAspectRatioMode', 'auto' )
set(H.image, 'Position',H.pos);
function binary_Callback(hObject, eventdata, H)
binaryImage1 = H.binaryImage1;
blobBoundingBox1 = H.blobBoundingBox1;
N1 = H.N1;
blobCentroid1 = H.blobCentroid1;

set(H.binary,'Value',1)
set(H.grayscale,'Value',0)

if get(H.unknowns,'Value') == 1
	axes(H.image)
	hold on
	if get(H.grayscale,'Value') == 1
		set(H.binary,'Value',0)
		imshow(originalImage1); 
	elseif get(H.binary,'Value') == 1
		set(H.grayscale,'Value',0)
		imshow(binaryImage1); 
	end
	bb = [blobBoundingBox1{N1,1}];
	rec1 = rectangle('Position', [bb(1,1),bb(1,2),bb(1,3),bb(1,4)],'EdgeColor','r','LineWidth',3);
	thisCentroid = blobCentroid1(N1,:);
	cen1 = scatter(thisCentroid(1,1),thisCentroid(1,2),100,'filled');
end

set(H.image, 'DataAspectRatioMode', 'auto' )
set(H.image, 'Position',H.pos);
function listbox1_Callback(hObject, eventdata, H)

sel = get(H.listbox1,'Value');

theta = [linspace(0,2*pi) 0];

cla(H.selected,'reset'); 

originalImage1 = H.originalImage1;
binaryImage1 = H.binaryImage1;

axes(H.selected)
hold on
if get(H.grayscale,'Value') == 1
	set(H.binary,'Value',0)
	imshow(originalImage1); 
elseif get(H.binary,'Value') == 1
	set(H.grayscale,'Value',0)
	imshow(binaryImage1); 
end

if H.circles == 0
	blobBoundingBox1 = H.blobBoundingBox1;
	blobBoundaries1 = H.blobBoundaries1;
	blobCentroid1 = H.blobCentroid1;
	thisCentroid = blobCentroid1(sel,:);


	
	thisBoundary = blobBoundaries1{sel};
	bb = [blobBoundingBox1{sel,1}];
end

	cen1 = H.cen1;
	set(cen1,'Visible','off')
	delete(cen1)

	rec1 = H.rec1;
	set(rec1,'Visible','off')
	delete(rec1)




if H.circles == 1	
	blobBoundingBox2 = H.blobBoundingBox2;
	blobBoundaries2 = H.blobBoundaries2;
	blobCentroid2 = H.blobCentroid2;	
	thisCentroid = blobCentroid2(sel,:);
	blobRadius2 = H.blobRadius2;
	blobCenterx2 = H.blobCenterx2;
	blobCentery2 = H.blobCentery2;

	for k = 1:length(blobBoundingBox2)
		BB = blobBoundingBox2{k,1};
		plot(cos(theta)*blobRadius2(k,1)+blobCenterx2(k,1),sin(theta)*blobRadius2(k,1)+blobCentery2(k,1),'r', 'LineWidth', 2);
	end
	
	diamet = H.diamet;
	set(H.diameter1,'String',round(diamet(sel,1),1))
	bb = [blobBoundingBox2{sel,1}];
	thisBoundary = blobBoundaries2{sel};
end

plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
axis([bb(1,1), bb(1,1)+bb(1,3), bb(1,2), bb(1,2)+bb(1,4)])


axes(H.image)
rec1 = rectangle('Position', [bb(1,1),bb(1,2),bb(1,3),bb(1,4)],'EdgeColor','r','LineWidth',3);
cen1 = scatter(thisCentroid(1,1),thisCentroid(1,2),200,'filled');

H.cen1 = cen1;
H.rec1 = rec1;

guidata(hObject,H);
function savesession_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.mat','Save file');
save([path file],'H')
function loadsession_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector','MultiSelect','on');
fullpathname = strcat(pathname, filename);
%close(ZirconSpotFinder_0_02_radius_filter)
load(fullpathname,'H')
function listbox3_Callback(hObject, eventdata, H)
function listbox4_Callback(hObject, eventdata, H)
function num_unknowns_Callback(hObject, eventdata, H)
if H.run == 1
	run(hObject, eventdata, H)
end

if get(H.num_unknowns, 'Value') == 1
	n = 50;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
elseif get(H.num_unknowns, 'Value') == 2
	n = 100;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)	
elseif get(H.num_unknowns, 'Value') == 3
	n = 120;
	n_p = 34;
	n_s = 4;
	n_all = 158;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
end
if get(H.num_unknowns, 'Value') > 3
	n = (get(H.num_unknowns,'Value')-1)*50;
	n_p = n/5+10;
	n_s = n/25;
	n_all = n + n_p + n_s;
	set(H.num_primary,'String', n_p)
	set(H.num_primary1,'String', n + 1)
	set(H.num_primary2,'String', n + n_p)
	set(H.num_secondary,'String', n_s)
	set(H.num_secondary1,'String', n + n_p + 1)
	set(H.num_secondary2,'String', n_all)
end
function newname_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)
function newprimary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)
function newsecondary_Callback(hObject, eventdata, H)
run(hObject, eventdata, H)
function export_cleaning_Callback(hObject, eventdata, H)
[file,path] = uiputfile('*.scancsv','Save file');
dlmcell([path,file],H.OUT4_cleaning_shots)

function rad_thresh_Callback(hObject, eventdata, H)

function rad_check_Callback(hObject, eventdata, H)


% --- Executes on button press in old_version.
function old_version_Callback(hObject, eventdata, handles)
% hObject    handle to old_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of old_version


% --- Executes on button press in load_results.
function load_results_Callback(hObject, eventdata, H)
[filename pathname] = uigetfile({'*'},'File Selector'); %load the supplemental file with zircon age eHfT data

if ispc == 1
	fullpathname = char(strcat(pathname, '\', filename));
end
if ismac == 1
	fullpathname = char(strcat(pathname, '/', filename));
end

% Read in data, format is name header and two columns of info, for our example we use age + Hf, but any 2D data will work
[numbers text1, data] = xlsread(fullpathname);
numbers = num2cell(numbers);
% 
% [file,path] = uiputfile('*.xls','Save file');
% writetable(table(Macro_1_2_Output),[path file], 'FileType', 'spreadsheet', 'WriteVariableNames', 0);



d=0
