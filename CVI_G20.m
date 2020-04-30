%--------------------------------------------------------------------------
%
% G20 - CVI First Lab Work
% Alexandre Galambas - 86372
% Guilherme Galambas - 86430
% Ricardo Velhinho   - 86505
%
%--------------------------------------------------------------------------

% Config
format compact
clear all,
myPath = '.\Material\database\';
prompt = 'Enter image name: (E.g. Moedas1.jpg)';
titledlg = 'Image Name';
se = strel('disk',10);
mainMenuOptionAux = 0;
visualizationMenuAux = 0;

% Image Input
imageName = inputdlg(prompt, titledlg);
img = imread(strcat(myPath,imageName{1}));
imgM = imgaussfilt(img);
th = graythresh(imgM(:,:,1));
bw1 = im2bw(imgM(:,:,1), th);
bw1Closed = imclose(bw1, se);
[lb num]=bwlabel(bw1Closed);
rprops = regionprops('table', lb, 'Area', 'Centroid', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'EquivDiameter');
centers = rprops.Centroid;
perimeters = rprops.Perimeter;
areas = rprops.Area;
diameters = rprops.EquivDiameter;
radii = diameters/2;
imgBound = bwboundaries(bw1Closed, 'noholes');

% Main Menu

while mainMenuOptionAux ~= -1
    if mainMenuOptionAux == 0
        mainMenuOption = questdlg('Choose an option', 'Menu', 'Visualization', 'More Options', 'Close', 'Close');
        switch mainMenuOption
            case 'Visualization'
                mainMenuOptionAux = 1;
                visualizationMenuAux = 0;
            case 'More Options'
                mainMenuOptionAux = 2;
            otherwise
                mainMenuOptionAux = -1;
                delete(gcf);
                close all;
        end
    end

    if mainMenuOptionAux == 2
        mainMenuMoreOptions1 = questdlg('Choose an option', 'Menu', 'Geometrical transformation', 'More Options', 'Back', 'Back');
        switch mainMenuMoreOptions1
            case 'Geometrical transformation'
                mainMenuOptionAux = 3;
            case 'More Options'
                mainMenuOptionAux = 4;
            otherwise
                mainMenuOptionAux = 0;
                delete(gcf);
        end
    end

    if mainMenuOptionAux == 4;
        mainMenuMoreOptions2 = questdlg('Choose an option', 'Menu', 'Similarity', 'More Options', 'Back', 'Back');
        switch mainMenuMoreOptions2
            case 'Similarity'
                mainMenuOptionAux = 5;
            case 'More Options'
                mainMenuOptionAux = 6;
            otherwise
                mainMenuOptionAux = 2;
                delete(gcf);
        end
    end


    if mainMenuOptionAux == 6;
        mainMenuMoreOptions3 = questdlg('Choose an option', 'Menu', 'Heat Map', 'More Options', 'Back', 'Back');
        switch mainMenuMoreOptions3
            case 'Heat Map'
                mainMenuOptionAux = 7;
            case 'More Options'
                mainMenuOptionAux = 8;
            otherwise
                mainMenuOptionAux = 4;
                delete(gcf);
        end
    end


    if mainMenuOptionAux == 8;
        mainMenuMoreOptions4 = questdlg('Choose an option', 'Menu', 'Select another image', 'Back', 'Back');
        switch mainMenuMoreOptions4
            case 'Select another image'
                mainMenuOptionAux = 9;
            otherwise
                mainMenuOptionAux = 6;
                delete(gcf);
        end
    end
    
    % Visualization Menu

    if mainMenuOptionAux == 1 
        while visualizationMenuAux ~= -1
            if visualizationMenuAux == 0
                visualizationMenuOption = questdlg('Show visualization for', 'Visualization Menu', 'All objects', 'Specific object', 'Back', 'Back');
                switch visualizationMenuOption
                    case 'All objects'
                        visualizationMenuAux = 1;
                    case 'Specific object'
                        visualizationMenuAux = 2;
                    otherwise
                        mainMenuOptionAux = 0
                        visualizationMenuAux = -1
                        delete(gcf);
                end
            end
            
            if visualizationMenuAux == 1
                visualizationMenuOption = questdlg('Show', 'Visualization Menu', 'Count/Centroids/Perimeters/Area/Sharpness', 'Relative Distance', 'Back', 'Back');
                switch visualizationMenuOption
                    case 'Count/Centroids/Perimeters/Area/Sharpness'
                        visualizationMenuAux = 3;
                    case 'Relative Distance'
                        visualizationMenuAux = 4;
                    otherwise
                        visualizationMenuAux = 0;
                        delete(gcf);
                end
            end
            
            if visualizationMenuAux == 3
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                % Show count of objects
                subplot(2,3,1), imshow(img);
                hold on;
                for i = 1:length(imgBound)
                    coinBound = imgBound{i};
                    plot(coinBound(:,2), coinBound(:,1), 'r', 'LineWidth', 2);
                end
                title('Number of objects');
                text(10, 700,strcat('Number of Objects',{' '}, int2str(num)),'FontSize', 14, 'Color', 'Red');
                
                % Show centroids of objects
                subplot(2,3,2), imshow(img);
                hold on;
                plot(centers(:,1), centers(:,2), '.r', 'MarkerSize', 20);
                title('Centroids of objects');
                
                % Show perimeters of objects
                subplot(2,3,3), imshow(img);
                hold on;
                text(centers(:,1) - radii/2, centers(:,2), num2str(perimeters), 'FontSize', 8,'Color', 'Red');
                title('Perimeters of objects');
                
                % Show area of objects
                subplot(2,3,4), imshow(img);
                hold on;
                text(centers(:,1) - radii/2 , centers(:,2), num2str(areas), 'FontSize', 8,'Color', 'Red');
                title('Areas of objects');
                visualizationMenuAux = 0;
                
                % Show Sharpness
                
            end
               
            if visualizationMenuAux == 4
                % Show Relative Distance to an object
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                rel = [];
                dist = [];
                points = [];
                
                for i= 1:num
                    if num >= 7
                        subplot(3,3,i), imshow(img);
                    elseif num >= 4
                        subplot(2,3,i), imshow(img);
                    else
                        subplot(1,3,i), imshow(img);
                    end
                    hold on
                    rel = [];
                    dist = [];
                    points = [];
                    r = centers(i,1);
                    c = centers(i,2);
                    for j = 1:num
                        x = centers(j,1);
                        y = centers(j,2);
                        line = [r x;c y];
                        rel = cat(2, rel, line);
                        d = sqrt((r - x)^2 + (c - y)^2);
                        dist = cat(1,dist, d);
                        points = cat(2,points, [(r+x)/2 + 10;(c+y)/2 + 10]);
                    end
                    plot(rel(1,:)', rel(2,:)', 'r', 'LineWidth', 2);
                    text(points(1,:)', points(2,:)', num2str(dist), 'FontSize', 8,'Color', 'Black');
                end
                visualizationMenuAux = 0;
                    
            end
            
            if visualizationMenuAux == 2
                delete(gcf);
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                imshow(img);
                hold on;
                [r, c] = ginput(1);
                index = 0;
                inside = 0;
                for i = 1:num
                    x = centers(i,1);
                    y = centers(i,2);
                    d = sqrt((x - r)^2 + (y - c)^2) <= radii(i);
                    if d == 1
                        inside = 1;
                        r = x;
                        c = y;
                        index = i;
                        break;
                    else
                        inside = 0;
                    end
                end
                
                if inside == 0
                    visualizationMenuAux = 0;
                    break
                end
                
                close;
               
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                
                % Show centroid of selected object
                subplot(2,3,1), imshow(img);
                hold on;
                plot(r, c, '.r', 'MarkerSize', 20);
                title('Centroid');
                
                % Show perimeter of selected object
                subplot(2,3,2), imshow(img);
                hold on;
                text(r - radii(index)/2, c, num2str(perimeters(index)), 'FontSize', 8,'Color', 'Black');
                title('Perimeter');
                
                % Show area of selected object
                subplot(2,3,3), imshow(img);
                hold on;
                text(r - radii(index)/2 , c, num2str(areas(index)), 'FontSize', 8,'Color', 'Black');
                title('Area');
                
                % Show relative distance of selected object
                subplot(2,3,4), imshow(img);
                hold on;
                rel = [];
                
                for i = 1:num
                    x = centers(i,1);
                    y = centers(i,2);
                    line = [r x;c y];
                    rel = cat(2, rel, line);
                end
                plot(rel(1,:)', rel(2,:)', 'r', 'LineWidth', 2);
                
                dist = [];
                points = [];
                for i = 1:num
                    x = centers(i,1);
                    y = centers(i,2);
                    d = sqrt((r - x)^2 + (c - y)^2);
                    dist = cat(1,dist, d);
                    points = cat(2,points, [(r+x)/2 + 10;(c+y)/2 + 10]);
                end
                text(points(1,:)', points(2,:)', num2str(dist), 'FontSize', 8,'Color', 'Black');
                title('Relative Distance');
                
                % Show sharpness of selected object
                
                % Show amount of money
                visualizationMenuAux = 0;
            end
        end
    end
    
    %Choose another image
    if mainMenuOptionAux == 9
        imageName = inputdlg(prompt, titledlg);
        img = imread(strcat(myPath,imageName{1}));
        imgM = imgaussfilt(img);
        th = graythresh(imgM(:,:,1));
        bw1 = im2bw(imgM(:,:,1), th);
        bw1Closed = imclose(bw1, se);
        [lb num]=bwlabel(bw1Closed);
        rprops = regionprops('table', lb, 'Area', 'Centroid', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'EquivDiameter');
        centers = rprops.Centroid;
        perimeters = rprops.Perimeter;
        areas = rprops.Area;
        diameters = rprops.EquivDiameter;
        radii = diameters/2;
        imgBound = bwboundaries(bw1Closed, 'noholes');
        mainMenuOptionAux = 0;
    end
        
end




