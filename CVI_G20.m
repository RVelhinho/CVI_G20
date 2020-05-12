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
similMenu = 0;

% Image Input
imageName = inputdlg(prompt, titledlg);
img = imread(strcat(myPath,imageName{1}));
imgM = imgaussfilt(img);
th = graythresh(imgM(:,:,1));
bw1 = im2bw(imgM(:,:,1), th);
bw1Closed = imopen(bw1, se);

% Detect object collision
D = bwdist(~bw1Closed);
D = -D;
borderD = imhmin(D, 5);
L = watershed(borderD);
L(~bw1Closed) = 0;
imgAfter = bw1Closed;
imgAfter(~L) = 0;


[lb num]=bwlabel(imgAfter);
rprops = regionprops('table', lb, 'Area', 'BoundingBox', 'Centroid', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'EquivDiameter');
centers = rprops.Centroid;
perimeters = rprops.Perimeter;
areas = rprops.Area;
diameters = rprops.EquivDiameter;
bboxes = rprops.BoundingBox;
radii = diameters/2;
imgBound = bwboundaries(imgAfter, 'noholes');
sharps = [];
for i = 1:num
    imgGray = double(rgb2gray(img));
    [r, c] = size(imgGray);
    %imgMini = img(floor(bboxes(i,2)): ceil(bboxes(i,2) + bboxes(i,4)), floor(bboxes(i,1)): ceil(bboxes(i,1) + bboxes(i,3)),:);
    coinBound = imgBound{i};
    sharpMask = poly2mask(coinBound(:,2), coinBound(:,1), r, c);
    imgGray(~sharpMask) = 0;
    [Fx, Fy] = gradient(imgGray);
    F=sqrt((Fx.^2) + (Fy.^2));
    sharpness=sum(sum(F))./(numel(F));
    sharps = cat(1, sharps, sharpness);
end
sharpsTable = table(sharps);
rprops = [rprops sharpsTable];
splotrows = 0;
if num >= 7
    splotrows = 3;
elseif num >= 4
    splotrows = 2;
else
    splotrows = 1;
end

% Application

while mainMenuOptionAux ~= -1
    
    % Main Menu
    
   
    choice = menu('Main Menu', 'Visualization', 'Geometrical transformation', 'Select another image', 'Close');
    switch choice
        case 1 % Visualization
            visualizationMenuOptionAux = 0;

            % Visualization Menu

            while visualizationMenuOptionAux ~= -1
                choice = menu('Visualization', 'All objects', 'Specific object', 'Back');
                switch choice
                    case 1 % All objects
                        allObjectsMenu = 0;

                        % Show options for all objects analysis

                        while allObjectsMenu ~= 1
                            if allObjectsMenu == 0
                                choice = menu('All objects', 'Ordered', 'Unordered', 'Back');
                                switch choice
                                    case 1 % Ordered
                                        orderedOptionsMenu = 0;

                                        % Ordered options

                                        while orderedOptionsMenu ~= -1
                                            if orderedOptionsMenu == 0
                                                choice = menu('Ordered', 'Perimeter', 'Area', 'Relative distance', 'Sharpness', 'Back');
                                                switch choice
                                                    case 1 % Perimeter
                                                        orderDirectionMenu = 0;

                                                        % Order by perimeter

                                                        while orderDirectionMenu ~= 1
                                                            if orderDirectionMenu == 0
                                                                choice = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                                rpropsSorted = [];
                                                                switch choice
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
                                                                centersSorted = rpropsSorted.Centroid;
                                                                perimetersSorted = rpropsSorted.Perimeter;
                                                                for i = 1:num
                                                                    subplot(splotrows, 3,i); imshow(img);
                                                                    hold on;
                                                                    text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(perimetersSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                end
                                                            end
                                                        end
                                                    case 2 % Area
                                                        orderDirectionMenu = 0;

                                                        % Order by area

                                                        while orderDirectionMenu ~= -1
                                                            choice = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                            rpropsSorted = [];
                                                            switch choice
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
                                                            centersSorted = rpropsSorted.Centroid;
                                                            areasSorted = rpropsSorted.Area;
                                                            for i = 1:num
                                                                subplot(splotrows, 3,i); imshow(img);
                                                                hold on;
                                                                text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(areasSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                            end
                                                        end
                                                    case 3 % Relative distance
                                                        
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
                                                        dist = [];
                                                        points = [];
                                                        line = [];
                                                        for i = 1:num
                                                            x = centers(i,1);
                                                            y = centers(i,2);
                                                            d = sqrt((r - x)^2 + (c - y)^2);
                                                            dist = cat(1,dist, d);
                                                            points = cat(1,points, [(r+x)/2 (c+y)/2]);
                                                        end
                                                        distTable = table(dist, points);
                                                        rpropsNew = [rprops distTable];
                                                        orderDirectionMenu = 0;

                                                        % Order by area

                                                        while orderDirectionMenu ~= -1
                                                            choice = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                            rpropsSorted = [];
                                                            switch choice
                                                                case 'Ascending'
                                                                    rpropsSorted = sortrows(rpropsNew, 'dist', 'ascend');
                                                                case 'Descending'
                                                                    rpropsSorted = sortrows(rpropsNew, 'dist', 'descend');
                                                                otherwise
                                                                    orderDirectionMenu = -1;
                                                                    orderedOptionsMenu = 0;
                                                                    delete(gcf);
                                                            end
                                                            if orderDirectionMenu == -1
                                                                break;
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
                                                        end
                                                    case 4 % Sharpness
                                                        orderDirectionMenu = 0;

                                                        % Order by
                                                        % Sharpness

                                                        while orderDirectionMenu ~= -1
                                                            if orderDirectionMenu == 0
                                                                choice = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                                rpropsSorted = [];
                                                                switch choice
                                                                    case 'Ascending'
                                                                        rpropsSorted = sortrows(rprops, 'sharps', 'ascend');
                                                                    case 'Descending'
                                                                        rpropsSorted = sortrows(rprops, 'sharps', 'descend');
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
                                                                centersSorted = rpropsSorted.Centroid;
                                                                sharpsSorted = rpropsSorted.sharps;
                                                                for i = 1:num
                                                                    subplot(splotrows, 3,i); imshow(img);
                                                                    hold on;
                                                                    text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(sharpsSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                end
                                                            end
                                                        end
                                                    otherwise
                                                        orderedOptionsMenu = -1;
                                                        allObjectsMenu = 0;
                                                        delete(gcf);
                                                end
                                            end
                                        end
                                    case 2 % Unordered
                                        unorderedOptionsMenu = 0;

                                        % Unordered options

                                        while unorderedOptionsMenu ~= -1
                                            if unorderedOptionsMenu == 0
                                                choice = menu('Unordered', 'Count/Centroids/Perimeters/Area/Sharpness', 'Relative Distance', 'Back');
                                                switch choice
                                                    case 1 % Count/Centroids/Perimeters/Area/Sharpness

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

                                                        subplot(2,3,5), imshow(img);
                                                        hold on;
                                                        text(centers(:,1) - radii/2 , centers(:,2), num2str(sharps), 'FontSize', 8,'Color', 'Red');
                                                        title('Sharpness of objects');

                                                    case 2 % Relative Distance

                                                        %Show unordered relative distance between objects

                                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                        rel = [];
                                                        dist = [];
                                                        points = [];
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

                    case 2 % Specific object
                        specificObjectMenu = 0;

                        % Show options for specific object analysis

                        while specificObjectMenu ~= -1
                            if specificObjectMenu == 0
                                choice = menu('Show specific object', 'Centroid/Perimeter/Area/Relative Distance/Sharpness', 'Geometrical transformation', 'Similarity', 'Back');
                                switch choice
                                    case 1 % Centroid/Perimeter/Area/Relative Distance/Sharpness

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

                                        subplot(2,3,5), imshow(img);
                                        hold on;
                                        text(r - radii(index)/2 , c, num2str(sharps(index)), 'FontSize', 8,'Color', 'Black');
                                        title('Sharpness');

                                        % Show amount of money

                                    case 2 % Geometrical transformation
                                    case 3 % Similarity
                                        similMenu = 0;

                                        % Similarity Options

                                        while similMenu ~= -1
                                            choice = menu('Similarity', 'Area', 'Perimeter', 'Sharpness', 'Back');
                                            switch choice
                                                case 1 % Area
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

                                                    areaSimil = [];
                                                    imgBoundNew = imgBound;
                                                    for i = 1:num
                                                        dif = abs(areas(index) - areas(i));
                                                        areaSimil = cat(1, areaSimil, dif);
                                                        imgBoundNew{i, 2} = dif;
                                                    end

                                                    areasSimilTable = table(areaSimil);
                                                    rpropsNew = [rprops areasSimilTable];

                                                    orderDirectionMenu = 0;

                                                    while orderDirectionMenu ~= -1
                                                        choice = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                        rpropsSorted = [];
                                                        switch choice
                                                            case 'Ascending'
                                                                rpropsSorted = sortrows(rpropsNew, 'areaSimil', 'ascend');
                                                                imgBoundSorted = sortrows(imgBoundNew, 2);
                                                            case 'Descending'
                                                                rpropsSorted = sortrows(rpropsNew, 'areaSimil', 'descend');
                                                                imgBoundSorted = sortrows(imgBoundNew, -2);
                                                            otherwise
                                                                orderDirectionMenu = -1;
                                                                similMenu = 0;
                                                                delete(gcf);
                                                        end
                                                        if orderDirectionMenu == -1
                                                            break
                                                        end
                                                        close;
                                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                        areaSimil = rpropsSorted.areaSimil;
                                                        centersSorted = rpropsSorted.Centroid;
                                                        for i = 1:num
                                                            subplot(splotrows, 3,i), imshow(img);
                                                            hold on
                                                            coinBound = imgBoundSorted{i};
                                                            plot(coinBound(:,2), coinBound(:,1), 'r', 'LineWidth', 2);
                                                            coinBound = imgBound{index};
                                                            plot(coinBound(:,2), coinBound(:,1), 'g', 'LineWidth', 2);
                                                            text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(areaSimil(i)), 'FontSize', 8,'Color', 'Black');
                                                        end
                                                    end
                                                case 2 % Perimeter
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

                                                    perimeterSimil = [];
                                                    imgBoundNew = imgBound;
                                                    for i = 1:num
                                                        dif = abs(perimeters(index) - perimeters(i));
                                                        perimeterSimil = cat(1, perimeterSimil, dif);
                                                        imgBoundNew{i, 2} = dif;
                                                    end

                                                    perimetersSimilTable = table(perimeterSimil);
                                                    rpropsNew = [rprops perimetersSimilTable];

                                                    orderDirectionMenu = 0;

                                                    while orderDirectionMenu ~= -1
                                                        choice = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                        rpropsSorted = [];
                                                        switch choice
                                                            case 'Ascending'
                                                                rpropsSorted = sortrows(rpropsNew, 'perimeterSimil', 'ascend');
                                                                imgBoundSorted = sortrows(imgBoundNew, 2);
                                                            case 'Descending'
                                                                rpropsSorted = sortrows(rpropsNew, 'perimeterSimil', 'descend');
                                                                imgBoundSorted = sortrows(imgBoundNew, -2);
                                                            otherwise
                                                                orderDirectionMenu = -1;
                                                                similMenu = 0;
                                                                delete(gcf);
                                                        end
                                                        if orderDirectionMenu == -1
                                                            break
                                                        end
                                                        close;
                                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                        perimeterSimil = rpropsSorted.perimeterSimil;
                                                        centersSorted = rpropsSorted.Centroid;
                                                        for i = 1:num
                                                            subplot(splotrows, 3,i), imshow(img);
                                                            hold on
                                                            coinBound = imgBoundSorted{i};
                                                            plot(coinBound(:,2), coinBound(:,1), 'r', 'LineWidth', 2);
                                                            coinBound = imgBound{index};
                                                            plot(coinBound(:,2), coinBound(:,1), 'g', 'LineWidth', 2);
                                                            text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(perimeterSimil(i)), 'FontSize', 8,'Color', 'Black');
                                                        end
                                                    end
                                                case 3 % Sharpness
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

                                                    sharpSimil = [];
                                                    imgBoundNew = imgBound;
                                                    for i = 1:num
                                                        dif = abs(sharps(index) - sharps(i));
                                                        sharpSimil = cat(1, sharpSimil, dif);
                                                        imgBoundNew{i, 2} = dif;
                                                    end

                                                    sharpSimilTable = table(sharpSimil);
                                                    rpropsNew = [rprops sharpSimilTable];

                                                    orderDirectionMenu = 0;

                                                    while orderDirectionMenu ~= -1
                                                        choice = questdlg('Order Direction', 'Visualization Menu', 'Ascending', 'Descending', 'Back', 'Back');
                                                        rpropsSorted = [];
                                                        switch choice
                                                            case 'Ascending'
                                                                rpropsSorted = sortrows(rpropsNew, 'sharpSimil', 'ascend');
                                                                imgBoundSorted = sortrows(imgBoundNew, 2);
                                                            case 'Descending'
                                                                rpropsSorted = sortrows(rpropsNew, 'sharpSimil', 'descend');
                                                                imgBoundSorted = sortrows(imgBoundNew, -2);
                                                            otherwise
                                                                orderDirectionMenu = -1;
                                                                similMenu = 0;
                                                                delete(gcf);
                                                        end
                                                        if orderDirectionMenu == -1
                                                            break
                                                        end
                                                        close;
                                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                        sharpSimil = rpropsSorted.sharpSimil;
                                                        centersSorted = rpropsSorted.Centroid;
                                                        for i = 1:num
                                                            subplot(splotrows, 3,i), imshow(img);
                                                            hold on
                                                            coinBound = imgBoundSorted{i};
                                                            plot(coinBound(:,2), coinBound(:,1), 'r', 'LineWidth', 2);
                                                            coinBound = imgBound{index};
                                                            plot(coinBound(:,2), coinBound(:,1), 'g', 'LineWidth', 2);
                                                            text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(sharpSimil(i)), 'FontSize', 8,'Color', 'Black');
                                                        end
                                                    end
                                                otherwise
                                                    similMenu = -1;
                                                    specificObjectMenu = 0;
                                            end
                                        end
                                    otherwise
                                        specificObjectMenu = -1;
                                        visualizationMenuOptionAux = 0;
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
        case 2 % Geometrical Transformation
        case 3 % Select another image
            imageName = inputdlg(prompt, titledlg);
            img = imread(strcat(myPath,imageName{1}));
            imgM = imgaussfilt(img);
            th = graythresh(imgM(:,:,1));
            bw1 = im2bw(imgM(:,:,1), th);
            bw1Closed = imclose(bw1, se);
            
            % Detect object collision
            D = bwdist(~bw1Closed);
            D = -D;
            borderD = imhmin(D, 5);
            L = watershed(borderD);
            L(~bw1Closed) = 0;
            imgAfter = bw1Closed;
            imgAfter(~L) = 0;
            
            [lb num]=bwlabel(imgAfter);
            rprops = regionprops('table', lb, 'Area','BoundingBox', 'Centroid', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'EquivDiameter');
            centers = rprops.Centroid;
            perimeters = rprops.Perimeter;
            areas = rprops.Area;
            diameters = rprops.EquivDiameter;
            radii = diameters/2;
            bboxes = rprops.BoundingBox;
            imgBound = bwboundaries(imgAfter, 'noholes');
            sharps = [];
            for i = 1:num
                imgGray = double(rgb2gray(img));
                [r, c] = size(imgGray);
                %imgMini = img(floor(bboxes(i,2)): ceil(bboxes(i,2) + bboxes(i,4)), floor(bboxes(i,1)): ceil(bboxes(i,1) + bboxes(i,3)),:);
                coinBound = imgBound{i};
                sharpMask = poly2mask(coinBound(:,2), coinBound(:,1), r, c);
                imgGray(~sharpMask) = 0;
                [Fx, Fy] = gradient(imgGray);
                F=sqrt((Fx.^2) + (Fy.^2));
                sharpness=sum(sum(F))./(numel(F));
                sharps = cat(1, sharps, sharpness);
            end
            sharpsTable = table(sharps);
            rprops = [rprops sharpsTable];
            splotrows = 0;
            if num >= 7
                splotrows = 3;
            elseif num >= 4
                splotrows = 2;
            else
                splotrows = 1;
            end
        otherwise
            mainMenuOptionAux = -1;
            delete(gcf);
            close all;
    end 
end




