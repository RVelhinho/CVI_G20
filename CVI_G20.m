%--------------------------------------------------------------------------
%
% G20 - CVI First Lab Work
% Alexandre Galambas - 86372
% Guilherme Galambas - 86430
% Ricardo Velhinho   - 86505
%
%--------------------------------------------------------------------------

% Config
clear all,
myPath = '.\Material\database\';
prompt = 'Enter image name: (E.g. Moedas1.jpg)';
title = 'Image Name';
se = strel('disk',10);
mainMenuOptionAux = 0;
visualizationMenuAux = 0;

% Image Input
imageName = inputdlg(prompt, title);

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
        while visualizationMenuAux == 0
            visualizationMenuOption = questdlg('Show visualization for', 'Visualization Menu', 'All objects', 'Select object', 'Back', 'Back');
            switch visualizationMenuOption
                case 'All objects'
                    visualizationMenuAux = 1;
                case 'Select object'
                    visualizationMenuAux = 2;
                otherwise
                    mainMenuOptionAux = 0
                    visualizationMenuAux = -1
                    delete(gcf);
            end
            if visualizationMenuAux == 1
                visualizationMenuAux = 0;
            end

            if visualizationMenuAux == 2
                visualizationMenuAux = 0;
            end
        end
    end
    
    %Choose another image
    if mainMenuOptionAux == 9
        imageName = inputdlg(prompt, title);
        mainMenuOptionAux = 0;
    end
        
end




% Visualization Menu

img = imread(strcat(myPath,imageName{1}));
imgM = imgaussfilt(img);
th = graythresh(imgM(:,:,1));
bw1 = im2bw(imgM(:,:,1), th);
bw1Closed = imclose(bw1, se);
[lb num]=bwlabel(bw1Closed);
rprops = regionprops(lb,'Area','BoundingBox','Centroid','Perimeter');
figure();
imshow(bw1Closed);

