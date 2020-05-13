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
clear all

choosingImage = true;
while choosingImage


    % Image Input

    myPath = '.\Material\database\';
    prompt = 'Enter image name:';
    titledlg = 'Image Name';
    sizedlg = [1 35];
    placeholder = {'Moedas1.jpg'};
    imageName = inputdlg(prompt, titledlg, sizedlg, placeholder);
    if size(imageName) == 0
        break;
    end
    img = imread(strcat(myPath,imageName{1}));


    % Image Processing

    imgM = imgaussfilt(img);
    th = graythresh(imgM(:,:,1));
    bw1 = im2bw(imgM(:,:,1), th);
    se = strel('disk',2);
    bw1Proc = imclose(bw1, se);
    

    % Resolve Collisions

    D = -bwdist(~bw1Proc);
    borderD = imhmin(D, 5);
    L = watershed(borderD);
    L(~bw1Proc);
    imgFinal = bw1Proc;
    imgFinal(~L) = 0;


    % Image Properties

    [lb, num]=bwlabel(imgFinal);
    rprops = regionprops('table', lb, 'Area', 'Centroid', 'Perimeter', 'EquivDiameter');

    centers = rprops.Centroid;
    perimeters = rprops.Perimeter;
    areas = rprops.Area;
    diameters = rprops.EquivDiameter;
    radii = diameters/2;

    imgBound = bwboundaries(imgFinal, 'noholes');
    rprops = [rprops table(imgBound)];
    

    % Relative Distances

    distances = zeros(num);
    lines = cell(num);
    points = cell(num);

    for i = 1:num

        r = centers(i,1);
        c = centers(i,2);

        for j = 1:num

            x = centers(j,1);
            y = centers(j,2);

            distances(i,j) = sqrt((r - x)^2 + (c - y)^2);
            lines{i,j} = [r x;c y];
            points{i,j} = [(r+x)/2 + 10, (c+y)/2 + 10];

        end
    end

    rprops = [rprops table(distances) table(lines) table(points)];

    % Sharpness

    sharps = [];
    for i = 1:num
        imgGray = double(rgb2gray(img));
        [r, c] = size(imgGray);
        coinBound = imgBound{i};
        sharpMask = poly2mask(coinBound(:,2), coinBound(:,1), r, c);
        imgGray(~sharpMask) = 0;
        [Fx, Fy] = gradient(imgGray);
        F=sqrt((Fx.^2) + (Fy.^2));
        sharpness=sum(sum(F))./(numel(F));
        sharps = cat(1, sharps, sharpness);
    end

    rprops = [rprops table(sharps)];
    
    
    % Money Count
    
    % Areas:
    %  0.01    10440 10295
    %  0.02    14278 14190
    %  0.05    17679
    %  0.10    15298 15366 15389
    %  0.20    19745 19295 19434 19392 19416
    %  0.50    23197 22993
    %  1.00    21254 21275 21393 21526
    % circle   21254
    
    coinValues = [0.01 0.02 0.05 0.10 0.20 0.50 1.00 2.00];
    coinAreas = [10368 14234 17697 15351 19456 23095 21362];
    areaError = 300;
    circularity = (4 .* pi .* areas) ./ (perimeters .^ 2);
    circError = 0.015;
    
    values = zeros(num, 1);
    for i = 1:num
        if abs(1 - circularity(i)) <= circError
            for coin = 1:length(coinAreas)
                if abs(areas(i) - coinAreas(coin)) <= areaError
                    values(i) = coinValues(coin);
                    break;
                end
            end
        end
    end
    
    rprops = [rprops table(values)];


    % Application
    
    splotrows = ceil(num/3);
    
    mainMenu = true;
    while mainMenu
        

        % Main Menu
        
        choice = menu('Main Menu', 'Visualization', 'Geometrical transformation', 'Money Count', 'Select another image', 'Close');
        switch choice


            case 1 % Visualization

                visMenu = true;
                while visMenu
                    choice = menu('Visualization', 'All objects', 'Specific object', 'Back');
                    switch choice


                        case 1 % All objects
                            
                            objectsMenu = true;
                            while objectsMenu
                                choice = menu('All objects', 'Ordered', 'Unordered', 'Back');
                                switch choice


                                    case 1 % Ordered

                                        orderedMenu = true;
                                        while orderedMenu
                                            choice = menu('Ordered', 'Perimeter', 'Area', 'Relative distance', 'Sharpness', 'Back');
                                            switch choice


                                                case 1 % Perimeter

                                                    directionMenu = true;
                                                    while directionMenu
                                                        choice = menu('Perimeter', 'Ascending', 'Descending', 'Back');
                                                        switch choice
                                                            case 1 % Ascending
                                                                rpropsSorted = sortrows(rprops, 'Perimeter', 'ascend');
                                                            case 2 % Descending
                                                                rpropsSorted = sortrows(rprops, 'Perimeter', 'descend');
                                                            case 3 % Back
                                                                delete(gcf);
                                                                directionMenu = false;
                                                            otherwise
                                                                delete(gcf);
                                                                directionMenu = false;
                                                                orderedMenu = false;
                                                                objectsMenu = false;
                                                                visMenu = false;
                                                                mainMenu = false;
                                                                choosingImage = false;
                                                                close all;
                                                        end
                                                        if directionMenu
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

                                                    directionMenu = true;
                                                    while directionMenu
                                                        choice = menu('Area', 'Ascending', 'Descending', 'Back');
                                                        switch choice
                                                            case 1 % Ascending
                                                                rpropsSorted = sortrows(rprops, 'Area', 'ascend');
                                                            case 2 % Descending
                                                                rpropsSorted = sortrows(rprops, 'Area', 'descend');
                                                            case 3 % Back
                                                                delete(gcf);
                                                                directionMenu = false;
                                                            otherwise
                                                                delete(gcf);
                                                                directionMenu = false;
                                                                orderedMenu = false;
                                                                objectsMenu = false;
                                                                visMenu = false;
                                                                mainMenu = false;
                                                                choosingImage = false;
                                                                close all;
                                                        end
                                                        if directionMenu
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
                                                    end


                                                case 3 % Relative Distance
                                                
                                                    % Choose Object
                                                    delete(gcf);
                                                    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                    imshow(img);
                                                    hold on;

                                                    inside = false;
                                                    while ~inside
                                                        [r, c] = ginput(1);

                                                        for i = 1:num
                                                            x = centers(i,1);
                                                            y = centers(i,2);
                                                            inside = sqrt((x - r)^2 + (y - c)^2) <= radii(i);

                                                            if inside
                                                                selected = i;
                                                                break;
                                                            end

                                                        end
                                                    end
                                                    close;

                                                    % Show Distances
                                                    directionMenu = true;
                                                    while directionMenu
                                                        choice = menu('Relative Distance', 'Ascending', 'Descending', 'Back');
                                                        switch choice
                                                            case 1 % Ascending
                                                                rpropsSorted = sortrows(rprops, 'distances', 'ascend');
                                                            case 2 % Descending
                                                                rpropsSorted = sortrows(rprops, 'distances', 'descend');
                                                            case 3 % Back
                                                                delete(gcf);
                                                                directionMenu = false;
                                                            otherwise
                                                                delete(gcf);
                                                                directionMenu = false;
                                                                orderedMenu = false;
                                                                objectsMenu = false;
                                                                visMenu = false;
                                                                mainMenu = false;
                                                                choosingImage = false;
                                                                close all;
                                                        end
                                                        if directionMenu
                                                            delete(gcf);
                                                            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                            distSorted = rpropsSorted.distances;
                                                            lineSorted = rpropsSorted.lines;
                                                            pointSorted = rpropsSorted.points;
                                                            pos = 1;
                                                            for i = 1:num
                                                                if i ~= selected
                                                                    subplot(splotrows, 3,pos); imshow(img);
                                                                    pos = pos + 1;
                                                                    hold on;
                                                                    plot(lineSorted{selected, i}(1,:)', lineSorted{selected, i}(2,:)','r', 'LineWidth', 2);
                                                                    text(pointSorted{selected, i}(1), pointSorted{selected, i}(2), num2str(distSorted(selected, i)), 'FontSize', 8,'Color', 'Black');
                                                                end
                                                            end
                                                        end
                                                    end


                                                case 4 % Sharpness

                                                    directionMenu = true;
                                                    while directionMenu
                                                        choice = menu('Sharpness', 'Ascending', 'Descending', 'Back');
                                                        switch choice
                                                            case 1 % Ascending
                                                                rpropsSorted = sortrows(rprops, 'sharps', 'ascend');
                                                            case 2 % Descending
                                                                rpropsSorted = sortrows(rprops, 'sharps', 'descend');
                                                            case 3 % Back
                                                                delete(gcf);
                                                                directionMenu = false;
                                                            otherwise
                                                                delete(gcf);
                                                                directionMenu = false;
                                                                orderedMenu = false;
                                                                objectsMenu = false;
                                                                visMenu = false;
                                                                mainMenu = false;
                                                                choosingImage = false;
                                                                close all;
                                                        end
                                                        if directionMenu
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
                                                    

                                                case 5 % Back

                                                    orderedMenu = false;


                                                otherwise % Close

                                                    orderedMenu = false;
                                                    objectsMenu = false;
                                                    visMenu = false;
                                                    mainMenu = false;
                                                    choosingImage = false;
                                                    close all;
                                            end
                                        end


                                    case 2 % Unordered

                                        unorderedMenu = true;
                                        while unorderedMenu
                                            choice = menu('Unordered', 'Count/Centroid/Perimeter/Area/Sharpness', 'Relative Distance', 'Back');
                                            switch choice


                                                case 1 % Count/Centroid/Perimeter/Area/Sharpness
                                                    
                                                    delete(gcf);
                                                    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                    
                                                    % Count
                                                    subplot(2,3,1), imshow(img);
                                                    hold on;
                                                    for i = 1:length(imgBound)
                                                        coinBound = imgBound{i};
                                                        plot(coinBound(:,2), coinBound(:,1), 'r', 'LineWidth', 2);
                                                    end
                                                    title('Number of objects');
                                                    text(10, 700,strcat('Number of Objects:', {' '}, int2str(num)),'FontSize', 14, 'Color', 'Red');
                                        
                                                    
                                                    % Centroid
                                                    subplot(2,3,2), imshow(img);
                                                    hold on;
                                                    plot(centers(:,1), centers(:,2), '.r', 'MarkerSize', 20);
                                                    title('Centroids of objects');
                                        
                                                    
                                                    % Perimeter
                                                    subplot(2,3,3), imshow(img);
                                                    hold on;
                                                    text(centers(:,1) - radii/2, centers(:,2), num2str(perimeters), 'FontSize', 8,'Color', 'Red');
                                                    title('Perimeters of objects');
                                        
                                                    
                                                    % Area
                                                    subplot(2,3,4), imshow(img);
                                                    hold on;
                                                    text(centers(:,1) - radii/2 , centers(:,2), num2str(areas), 'FontSize', 8,'Color', 'Red');
                                                    title('Areas of objects');
                                        
                                                    
                                                    % Sharpness
                                                    subplot(2,3,5), imshow(img);
                                                    hold on;
                                                    text(centers(:,1) - radii/2 , centers(:,2), num2str(sharps), 'FontSize', 8,'Color', 'Red');
                                                    title('Sharpness of objects');
                                                    
                                                    
                                                case 2 % Relative Distance
                                                    
                                                    delete(gcf);
                                                    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                    
                                                    for i = 1:num
                                                        subplot(splotrows,3,i), imshow(img);
                                                        hold on
                                                        for j = 1:num
                                                            if j ~= i
                                                                plot(lines{i, j}(1,:)', lines{i, j}(2,:)','r', 'LineWidth', 2);
                                                                text(points{i, j}(1), points{i, j}(2), num2str(distances(i, j)), 'FontSize', 8,'Color', 'Black');
                                                            end
                                                        end
                                                    end


                                                case 3 % Back

                                                    delete(gcf);
                                                    unorderedMenu = false;


                                                otherwise % Close

                                                    delete(gcf);
                                                    unorderedMenu = false;
                                                    objectsMenu = false;
                                                    visMenu = false;
                                                    mainMenu = false;
                                                    choosingImage = false;
                                                    close all;
                                            end
                                        end


                                    case 3 % Back

                                        objectsMenu = false;


                                    otherwise % Close

                                        objectsMenu = false;
                                        visMenu = false;
                                        mainMenu = false;
                                        choosingImage = false;
                                        close all;
                                end
                            end

                        case 2 % Specific Object

                            objectsMenu = true;
                            while objectsMenu
                                choice = menu('Specific object', 'Centroid/Perimeter/Area/Relative Distance/Sharpness', 'Similarity', 'Heatmap', 'Back');
                                switch choice


                                    case 1 % Centroid/Perimeter/Area/Relative Distance/Sharpness
                                        
                                        % Choose Object
                                        delete(gcf);
                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                        imshow(img);
                                        hold on;

                                        inside = false;
                                        while ~inside
                                            [r, c] = ginput(1);

                                            for i = 1:num
                                                x = centers(i,1);
                                                y = centers(i,2);
                                                inside = sqrt((x - r)^2 + (y - c)^2) <= radii(i);

                                                if inside
                                                    selected = i;
                                                    break;
                                                end

                                            end
                                        end
                                        close;

                                        delete(gcf);
                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

                                        % Centroid
                                        subplot(2,3,1), imshow(img);
                                        hold on;
                                        plot(centers(selected,1), centers(selected,2), '.r', 'MarkerSize', 20);
                                        title('Centroid');

                                        % Perimeter
                                        subplot(2,3,2), imshow(img);
                                        hold on;
                                        text(r - radii(selected)/2, c, num2str(perimeters(selected)), 'FontSize', 8,'Color', 'Black');
                                        title('Perimeter');

                                        % Area
                                        subplot(2,3,3), imshow(img);
                                        hold on;
                                        text(r - radii(selected)/2 , c, num2str(areas(selected)), 'FontSize', 8,'Color', 'Black');
                                        title('Area');

                                        % Relative Distance
                                        subplot(2,3,4), imshow(img);
                                        hold on
                                        for i = 1:num
                                            if i ~= selected
                                                plot(lineSorted{selected, i}(1,:)', lineSorted{selected, i}(2,:)','r', 'LineWidth', 2);
                                                text(pointSorted{selected, i}(1), pointSorted{selected, i}(2), num2str(distSorted(selected, i)), 'FontSize', 8,'Color', 'Black');
                                            end
                                        end
                                        title('Relative Distance');

                                        % Sharpness
                                        subplot(2,3,5), imshow(img);
                                        hold on;
                                        text(r - radii(selected)/2 , c, num2str(sharps(selected)), 'FontSize', 8,'Color', 'Black');
                                        title('Sharpness');
                                        

                                    case 2 % Similarity

                                        simMenu = true;
                                        while simMenu
                                            choice = menu('Similarity', 'Perimeter', 'Area', 'Sharpness', 'Back');
                                            switch choice


                                                case 1 % Perimeter

                                                    % Choose Object
                                                    delete(gcf);
                                                    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                    imshow(img);
                                                    hold on;

                                                    inside = false;
                                                    while ~inside
                                                        [r, c] = ginput(1);

                                                        for i = 1:num
                                                            x = centers(i,1);
                                                            y = centers(i,2);
                                                            inside = sqrt((x - r)^2 + (y - c)^2) <= radii(i);

                                                            if inside
                                                                selected = i;
                                                                break;
                                                            end

                                                        end
                                                    end
                                                    close;

                                                    % Similarity
                                                    similarity = zeros(num, 1);
                                                    for i = 1:num
                                                        if i ~= selected
                                                            similarity(i) = abs(perimeters(selected) - perimeters(i));
                                                        end
                                                    end
                                                    rpropsNew = [rprops table(similarity)];

                                                    % Perimeter
                                                    directionMenu = true;
                                                    while directionMenu
                                                        choice = menu('Perimeter', 'Ascending', 'Descending', 'Back');
                                                        switch choice
                                                            case 1 % Ascending
                                                                rpropsSorted = sortrows(rpropsNew, 'similarity', 'ascend');
                                                            case 2 % Descending
                                                                rpropsSorted = sortrows(rpropsNew, 'similarity', 'descend');
                                                            case 3 % Back
                                                                delete(gcf);
                                                                directionMenu = false;
                                                            otherwise % Close
                                                                delete(gcf);
                                                                directionMenu = false;
                                                                simMenu = false;
                                                                objectsMenu = false;
                                                                visMenu = false;
                                                                mainMenu = false;
                                                                choosingImage = false;
                                                                close all;
                                                        end
                                                        if directionMenu
                                                            delete(gcf);
                                                            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                            centersSorted = rpropsSorted.Centroid;
                                                            simSorted = rpropsSorted.similarity;
                                                            boundSorted = rpropsSorted.imgBound;
                                                            pos = 1;
                                                            for i = 1:num
                                                                if i ~= selected
                                                                    subplot(splotrows,3,pos); imshow(img);
                                                                    pos = pos + 1;
                                                                    hold on;
                                                                    plot(boundSorted{i}(:,2), boundSorted{i}(:,1), 'r', 'LineWidth', 2);
                                                                    plot(imgBound{selected}(:,2), imgBound{selected}(:,1), 'g', 'LineWidth', 2);
                                                                    text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(simSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                end
                                                            end
                                                        end
                                                    end


                                                case 2 % Area

                                                    % Choose Object
                                                    delete(gcf);
                                                    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                    imshow(img);
                                                    hold on;

                                                    inside = false;
                                                    while ~inside
                                                        [r, c] = ginput(1);

                                                        for i = 1:num
                                                            x = centers(i,1);
                                                            y = centers(i,2);
                                                            inside = sqrt((x - r)^2 + (y - c)^2) <= radii(i);

                                                            if inside
                                                                selected = i;
                                                                break;
                                                            end

                                                        end
                                                    end
                                                    close;

                                                    % Similarity
                                                    similarity = zeros(num, 1);
                                                    for i = 1:num
                                                        if i ~= selected
                                                            similarity(i) = abs(areas(selected) - areas(i));
                                                        end
                                                    end
                                                    rpropsNew = [rprops table(similarity)];

                                                    % Area
                                                    directionMenu = true;
                                                    while directionMenu
                                                        choice = menu('Area', 'Ascending', 'Descending', 'Back');
                                                        switch choice
                                                            case 1 % Ascending
                                                                rpropsSorted = sortrows(rpropsNew, 'similarity', 'ascend');
                                                            case 2 % Descending
                                                                rpropsSorted = sortrows(rpropsNew, 'similarity', 'descend');
                                                            case 3 % Back
                                                                delete(gcf);
                                                                directionMenu = false;
                                                            otherwise % Close
                                                                delete(gcf);
                                                                directionMenu = false;
                                                                simMenu = false;
                                                                objectsMenu = false;
                                                                visMenu = false;
                                                                mainMenu = false;
                                                                choosingImage = false;
                                                                close all;
                                                        end
                                                        if directionMenu
                                                            delete(gcf);
                                                            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                            centersSorted = rpropsSorted.Centroid;
                                                            simSorted = rpropsSorted.similarity;
                                                            boundSorted = rpropsSorted.imgBound;
                                                            pos = 1;
                                                            for i = 1:num
                                                                if i ~= selected
                                                                    subplot(splotrows,3,pos); imshow(img);
                                                                    pos = pos + 1;
                                                                    hold on;
                                                                    plot(boundSorted{i}(:,2), boundSorted{i}(:,1), 'r', 'LineWidth', 2);
                                                                    plot(imgBound{selected}(:,2), imgBound{selected}(:,1), 'g', 'LineWidth', 2);
                                                                    text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(simSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                end
                                                            end
                                                        end
                                                    end


                                                case 3 % Sharpness

                                                    % Choose Object
                                                    delete(gcf);
                                                    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                    imshow(img);
                                                    hold on;

                                                    inside = false;
                                                    while ~inside
                                                        [r, c] = ginput(1);

                                                        for i = 1:num
                                                            x = centers(i,1);
                                                            y = centers(i,2);
                                                            inside = sqrt((x - r)^2 + (y - c)^2) <= radii(i);

                                                            if inside
                                                                selected = i;
                                                                break;
                                                            end

                                                        end
                                                    end
                                                    close;

                                                    % Similarity
                                                    similarity = zeros(num, 1);
                                                    for i = 1:num
                                                        if i ~= selected
                                                            similarity(i) = abs(sharps(selected) - sharps(i));
                                                        end
                                                    end
                                                    rpropsNew = [rprops table(similarity)];

                                                    % Sharpness
                                                    directionMenu = true;
                                                    while directionMenu
                                                        choice = menu('Sharpness', 'Ascending', 'Descending', 'Back');
                                                        switch choice
                                                            case 1 % Ascending
                                                                rpropsSorted = sortrows(rpropsNew, 'similarity', 'ascend');
                                                            case 2 % Descending
                                                                rpropsSorted = sortrows(rpropsNew, 'similarity', 'descend');
                                                            case 3 % Back
                                                                delete(gcf);
                                                                directionMenu = false;
                                                            otherwise % Close
                                                                delete(gcf);
                                                                directionMenu = false;
                                                                simMenu = false;
                                                                objectsMenu = false;
                                                                visMenu = false;
                                                                mainMenu = false;
                                                                choosingImage = false;
                                                                close all;
                                                        end
                                                        if directionMenu
                                                            delete(gcf);
                                                            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                                            centersSorted = rpropsSorted.Centroid;
                                                            simSorted = rpropsSorted.similarity;
                                                            boundSorted = rpropsSorted.imgBound;
                                                            pos = 1;
                                                            for i = 1:num
                                                                if i ~= selected
                                                                    subplot(splotrows,3,pos); imshow(img);
                                                                    pos = pos + 1;
                                                                    hold on;
                                                                    plot(boundSorted{i}(:,2), boundSorted{i}(:,1), 'r', 'LineWidth', 2);
                                                                    plot(imgBound{selected}(:,2), imgBound{selected}(:,1), 'g', 'LineWidth', 2);
                                                                    text(centersSorted(i,1) - radii(i)/2, centersSorted(i,2), num2str(simSorted(i)), 'FontSize', 8,'Color', 'Black');
                                                                end
                                                            end
                                                        end
                                                    end


                                                case 4 % Back

                                                    simMenu = false;
                                                    

                                                otherwise % Close

                                                    simMenu = false;
                                                    objectsMenu = false;
                                                    visMenu = false;
                                                    mainMenu = false;
                                                    choosingImage = false;
                                                    close all;
                                            end
                                        end


                                    case 3 % Heatmap
            
                                        % Choose Object
                                        delete(gcf);
                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                        imshow(img);
                                        hold on;

                                        inside = false;
                                        while ~inside
                                            [r, c] = ginput(1);

                                            for i = 1:num
                                                x = centers(i,1);
                                                y = centers(i,2);
                                                inside = sqrt((x - r)^2 + (y - c)^2) <= radii(i);

                                                if inside
                                                    selected = i;
                                                    break;
                                                end

                                            end
                                        end
                                        close;

                                        % Heatmap
                                        [h, w, d] = size(img);
                                        X = [centers(:,1)' 0 0 w w]'
                                        Y = [centers(:,2)' 0 h 0 h]'
                                        dist = [];

                                        for i = 1:length(X)
                                            d = sqrt((x - X(i))^2 + (y - Y(i))^2);
                                            dist = cat(1, dist, d);
                                        end

                                        distPercent = (dist*100)/sqrt((h^2)+(w^2));

                                        heatmap = [];
                                        F = scatteredInterpolant(Y, X, distPercent, 'natural');
                                        for i = 1:h
                                            for j = 1:w
                                                heatmap(i,j) = F(i,j);
                                            end
                                        end
                                        alpha = (~isnan(heatmap))*0.6;
                                        
                                        delete(gcf);
                                        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                                        imshow(img);
                                        hold on

                                        heatmap = imshow(heatmap);
                                        caxis auto;
                                        % colormap( heatmap.Parent, jet );
                                        colormap( heatmap.Parent, flipud(jet) );
                                        colorbar( heatmap.Parent );
                                        set( heatmap, 'AlphaData', alpha );


                                    case 4 % Back
            
                                        objectsMenu = false;


                                    otherwise % Close

                                        objectsMenu = false;
                                        visMenu = false;
                                        mainMenu = false;
                                        choosingImage = false;
                                        close all;
                                end
                            end


                        case 3 % Back

                            visMenu = false;


                        otherwise % Close

                            visMenu = false;
                            mainMenu = false;
                            choosingImage = false;
                            close all;
                    end
                end


            case 2 % Geometrical Transformation
                                                
                % Choose Object
                delete(gcf);
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                imshow(img);
                hold on;

                inside = false;
                while ~inside
                    [r, c] = ginput(1);

                    for i = 1:num
                        x = centers(i,1);
                        y = centers(i,2);
                        inside = sqrt((x - r)^2 + (y - c)^2) <= radii(i);

                        if inside
                            selected = i;
                            break;
                        end

                    end
                end
                close;

                % Geometrical Transformation
                c = imgBound{selected}(:,2).';
                r = imgBound{selected}(:,1).';
                imgPoly = roipoly(img, c, r);
                mask = cast(imgPoly, class(img));
                imgCropped = img .* repmat(mask, [1 1 3]);
                imgCropped = imcrop(imgCropped, [min(c) min(r) max(c)-min(c) max(r)-min(r)]);
                rotation = 60;
                imgRotated = imrotate(imgCropped, rotation, 'nearest', 'crop');
                resize = 1.5;
                imgResized = imresize(imgRotated, resize);
                
                r = imgResized(:, :, 1);
                g = imgResized(:, :, 2);
                b = imgResized(:, :, 3);
                mask = r ~= 0 & g ~= 0 & b ~= 0;

                imgSize = size(imgResized);
                x2 = x - imgSize(2)/2
                y2 = y - imgSize(1)/2

                delete(gcf);
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

                subplot(1,2,1); imshow(img);
                hold on;
                plot(imgBound{selected}(:,2), imgBound{selected}(:,1), 'r', 'LineWidth', 2);
                title('Original Image');
                
                subplot(1,2,2); imshow(img);
                hold on;
                image(x2, y2, imgResized, 'AlphaData', mask);
                title('Geometrical transformation');
                text(10, 700,strcat('Rotation:', {' '}, num2str(rotation), 'o | Size:', {' '}, num2str(resize), 'x'),'FontSize', 16, 'Color', 'Black');


            case 3 % Money Count
                
                delete(gcf);
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
                imshow(img);
                hold on;

                for i = 1:length(imgBound)
                    if values(i) > 0
                        coinBound = imgBound{i};
                        plot(coinBound(:,2), coinBound(:,1), 'y', 'LineWidth', 3);
                        text(centers(i,1) - radii(i)/2, centers(i,2), strcat(num2str(values(i)), '€'), 'FontSize', 14, 'Color', 'Black');
                    end
                end

                title('Money Count');
                text(10, 700,strcat('Total Money:', {' '}, num2str(sum(values)), '€'),'FontSize', 16, 'Color', 'Black');

                
            case 4 % Select another image

                mainMenu = false;
                delete(gcf);


            otherwise % Close

                mainMenu = false;
                choosingImage = false;
                delete(gcf);
                close all;
        end 
    end
end