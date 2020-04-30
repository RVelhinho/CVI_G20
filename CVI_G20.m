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
visualizationMenuOptionAux = 0;
allObjectsMenu = 0;
specificObjectMenu = 0;
orderedOptionsMenu = 0;
unorderedOptionsMenu = 0;
orderDirectionMenu = 0;

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

% Application

while mainMenuOptionAux ~= -1
    
    % Main Menu
    
    if mainMenuOptionAux == 0
        mainMenuOption = questdlg('Choose an option', 'Menu', 'Visualization', 'More Options', 'Close', 'Close');
        switch mainMenuOption
            case 'Visualization'
                visualizationMenuOptionAux = 0;
                
                % Visualization Menu
                
                while visualizationMenuOptionAux ~= -1
                    if visualizationMenuOptionAux == 0
                        question = questdlg('Show visualization for', 'Visualization Menu', 'All objects', 'Specific object', 'Back', 'Back');
                        switch question
                            case 'All objects'
                                allObjectsMenu = 0;
                                
                                % Show options for all objects analysis
                                
                                while allObjectsMenu ~= 1
                                    if allObjectsMenu == 0
                                        question = questdlg('Show', 'All objects', 'Ordered', 'Unordered', 'Back', 'Back');
                                        switch question
                                            case 'Ordered'
                                                orderedOptionsMenu = 0;
                                                
                                                % Ordered options
                                                 
                                                while orderedOptionsMenu ~= -1
                                                    if orderedOptionsMenu == 0
                                                        question = questdlg('Order by', 'Visualization Menu', 'Perimeter', 'More Options', 'Back', 'Back');
                                                        switch question
                                                            case 'Perimeter'
                                                                orderDirectionMenu = 0;
                                                                
                                                                % Order by perimeter
                
                                                                while orderDirectionMenu ~= 1
                                                                    if orderDirectionMenu == 0
                                                                        question = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                                        rpropsSorted = [];
                                                                        switch question
                                                                            case 'Ascending'
                                                                                rpropsSorted = sortrows(rprops, 'Perimeter', 'ascend');
                                                                            case 'Descending'
                                                                                rpropsSorted = sortrows(rprops, 'Perimeter', 'descend');
                                                                            otherwise
                                                                                orderDirectionMenu = -1;
                                                                                orderedOptionsMenu = 0;
                                                                                delete(gcf);
                                                                        end
                                                                        if orderDirectionMenu == -1
                                                                            break
                                                                        end
                                                                        delete(gcf);
                                                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                                        splotrows = 0;
                                                                        centersSorted = rpropsSorted.Centroid;
                                                                        perimetersSorted = rpropsSorted.Perimeter;
                                                                        if num >= 7
                                                                            splotrows = 3;
                                                                        elseif num >= 4
                                                                            splotrows = 2;
                                                                        else
                                                                            splotrows = 1;
                                                                        end
                                                                        for i = 1:num
                                                                            subplot(splotrows, 3,i); imshow(img);
                                                                            hold on;
                                                                            text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(perimetersSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                        end
                                                                    end
                                                                end
                                                            case 'More Options'
                                                                orderedOptionsMenu = 1;
                                                            otherwise
                                                                orderedOptionsMenu = -1;
                                                                allObjectsMenu = 0;
                                                                delete(gcf);
                                                        end
                                                    end

                                                    if orderedOptionsMenu == 1
                                                        question = questdlg('Order by', 'Visualization Menu', 'Area', 'More Options', 'Back', 'Back');
                                                        switch question
                                                            case 'Area'
                                                                orderDirectionMenu = 0;
                                                                
                                                                % Order by area

                                                                while orderDirectionMenu ~= -1
                                                                    if orderDirectionMenu == 0
                                                                        question = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                                        rpropsSorted = [];
                                                                        switch question
                                                                            case 'Ascending'
                                                                                rpropsSorted = sortrows(rprops, 'Area', 'ascend');
                                                                            case 'Descending'
                                                                                rpropsSorted = sortrows(rprops, 'Area', 'descend');
                                                                            otherwise
                                                                                orderDirectionMenu = -1;
                                                                                orderedOptionsMenu = 0;
                                                                                delete(gcf);
                                                                        end
                                                                        if orderDirectionMenu == -1
                                                                            break
                                                                        end
                                                                        delete(gcf);
                                                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                                        splotrows = 0;
                                                                        centersSorted = rpropsSorted.Centroid;
                                                                        areasSorted = rpropsSorted.Area;
                                                                        if num >= 7
                                                                            splotrows = 3;
                                                                        elseif num >= 4
                                                                            splotrows = 2;
                                                                        else
                                                                            splotrows = 1;
                                                                        end
                                                                        for i = 1:num
                                                                            subplot(splotrows, 3,i); imshow(img);
                                                                            hold on;
                                                                            text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(areasSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                        end
                                                                    end
                                                                end
                                                            case 'More Options'
                                                                orderedOptionsMenu = 2;
                                                            otherwise
                                                                orderedOptionsMenu = 0;
                                                                delete(gcf);
                                                        end
                                                    end

                                                    if orderedOptionsMenu == 2
                                                        question = questdlg('Order by', 'Visualization Menu', 'Relative Distance', 'Sharpness', 'Back', 'Back');
                                                        switch question
                                                            case 'Relative Distance'
                                                                
                                                                % Order by relative distance
                                                                
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
                                                                    orderedOptionsMenu = 0;
                                                                    break
                                                                end

                                                                close;
                                                                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                                splotrows = 0;
                                                                dist = [];
                                                                points = [];
                                                                line = [];
                                                                if num >= 7
                                                                    splotrows = 3;
                                                                elseif num >= 4
                                                                    splotrows = 2;
                                                                else
                                                                    splotrows = 1;
                                                                end
                                                                for i = 1:num
                                                                    x = centers(i,1);
                                                                    y = centers(i,2);
                                                                    d = sqrt((r - x)^2 + (c - y)^2);
                                                                    dist = cat(1,dist, d);
                                                                    points = cat(1,points, [(r+x)/2 (c+y)/2]);
                                                                end
                                                                distTable = table(dist, points);
                                                                rpropsNew = [rprops distTable];
                                                                question = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                                rpropsSorted = [];
                                                                switch question
                                                                    case 'Ascending'
                                                                        rpropsSorted = sortrows(rpropsNew, 'dist', 'ascend');
                                                                    case 'Descending'
                                                                        rpropsSorted = sortrows(rpropsNew, 'dist', 'descend');
                                                                    otherwise
                                                                        delete(gcf);
                                                                end
                                                                centersSorted = rpropsSorted.Centroid;
                                                                distSorted = rpropsSorted.dist;
                                                                pointSorted = rpropsSorted.points;
                                                                for i = 1:num
                                                                    subplot(splotrows, 3,i); imshow(img);
                                                                    hold on;
                                                                    line = [r centersSorted(i,1);c centersSorted(i,2)];
                                                                    plot( line(1,:)', line(2,:)','r', 'LineWidth', 2);
                                                                    text(points(i,1), points(i,2), num2str(distSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                end
                                                            case 'Sharpness'
                                                            otherwise
                                                                orderedOptionsMenu = 1;
                                                                delete(gcf);
                                                        end
                                                    end
                                                end
                                            case 'Unordered'
                                                unorderedOptionsMenu = 0;
                                                
                                                % Unordered options
                                                   
                                                while unorderedOptionsMenu ~= -1
                                                    if unorderedOptionsMenu == 0
                                                        question = questdlg('Show', 'Visualization Menu', 'Count/Centroids/Perimeters/Area/Sharpness', 'Relative Distance', 'Back', 'Back');
                                                        switch question
                                                            case 'Count/Centroids/Perimeters/Area/Sharpness'
                                                                
                                                                % Show unordered count/centroids/perimeters/areas/sharpness of
                                                                % all objects

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

                                                                % Show Sharpness

                                                            case 'Relative Distance'
                                                                
                                                                %Show unordered relative distance between objects
                                                                
                                                                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                                rel = [];
                                                                dist = [];
                                                                points = [];
                                                                splotrows = 0;

                                                                if num >= 7
                                                                    splotrows = 3;
                                                                elseif num >= 4
                                                                    splotrows = 2;
                                                                else
                                                                    splotrows = 1;
                                                                end

                                                                for i= 1:num
                                                                    subplot(splotrows,3,i), imshow(img);
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
                                                            otherwise
                                                                unorderedOptionsMenu = -1;
                                                                allObjectsMenu = 0;
                                                                delete(gcf);
                                                        end
                                                    end
                                                end
                                            otherwise
                                                visualizationMenuOptionAux = 0;
                                                allObjectsMenu = -1;
                                                delete(gcf);
                                                break;
                                        end
                                    end
                                end
                                
                            case 'Specific object'
                                specificObjectMenu = 0;
                                
                                % Show options for specific object analysis
                                
                                while specificObjectMenu ~= -1
                                    if specificObjectMenu == 0
                                        question = questdlg('Show', 'Specific object', 'Centroid/Perimeter/Area/Relative Distance/Sharpness', 'More Options', 'Back', 'Back');
                                        switch question
                                            case 'Centroid/Perimeter/Area/Relative Distance/Sharpness'
                                                
                                                % Show centroid, perimeter, area, relative distance and
                                                % sharpness for selected object

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
                                                    visualizationMenuOptionAux = 0;
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
                                                    
                                            case 'More Options'
                                                specificObjectMenu = 1;
                                            otherwise
                                                specificObjectMenu = -1;
                                                visualizationMenuOptionAux = 0;
                                                delete(gcf);
                                        end
                                    end

                                    if specificObjectMenu == 1
                                        question = questdlg('Show', 'Specific object', 'Geometrical transformation', 'Similarity', 'Back', 'Back');
                                        switch question
                                            case 'Geometrical transformation'
                                            case 'Similarity'
                                            otherwise
                                                specificObjectMenu = 0;
                                                delete(gcf);
                                        end
                                    end
                                end
                            otherwise
                                mainMenuOptionAux = 0;
                                visualizationMenuOptionAux = -1;
                                delete(gcf);
                        end
                    end
                end
            case 'More Options'
                mainMenuOptionAux = 1;
            otherwise
                mainMenuOptionAux = -1;
                delete(gcf);
                close all;
        end
    end

    if mainMenuOptionAux == 1
        mainMenuMoreOptions1 = questdlg('Choose an option', 'Menu', 'Geometrical transformation', 'More Options', 'Back', 'Back');
        switch mainMenuMoreOptions1
            case 'Geometrical transformation'
            case 'More Options'
                mainMenuOptionAux = 2;
            otherwise
                mainMenuOptionAux = 0;
                delete(gcf);
        end
    end

    if mainMenuOptionAux == 2;
        mainMenuMoreOptions4 = questdlg('Choose an option', 'Menu', 'Select another image', 'Back', 'Back');
        switch mainMenuMoreOptions4
            case 'Select another image'
                mainMenuOptionAux = 9;
            otherwise
                mainMenuOptionAux = 1;
                delete(gcf);
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




