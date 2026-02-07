clc;
clear;
close all;

%% ================== GLOBAL VARIABLES ==================
global SelectedItems RackDB mallFig ZoneItems Zones RackAccess;
SelectedItems = {};   % {ItemName, ZoneIndex, RackIndex}

%% ================== MAP SETUP ==================
mapW = 220;
mapH = 115;

figure('Name','2D Indoor Shopping Mall Layout (Fixed Map)','Color','w');
mallFig = gcf;

axis([0 mapW 0 mapH]);
axis equal;
hold on;
grid off;
set(gca,'XLimMode','manual','YLimMode','manual');

xlabel('X (meters - scaled)');
ylabel('Y (meters - scaled)');
title('2D Indoor Shopping Mall Layout (Fixed Map)');

rectangle('Position',[0 0 mapW mapH],'EdgeColor','k','LineWidth',2);

%% ================== AISLES ==================
aisleColor = [0.9 0.9 0.9];

rectangle('Position',[0 0 mapW 10],'FaceColor',aisleColor,'EdgeColor','none');
rectangle('Position',[0 50 mapW 15],'FaceColor',aisleColor,'EdgeColor','none');
rectangle('Position',[0 105 mapW 10],'FaceColor',aisleColor,'EdgeColor','none');

rectangle('Position',[0 0 10 mapH],'FaceColor',aisleColor,'EdgeColor','none');
rectangle('Position',[60 0 15 mapH],'FaceColor',aisleColor,'EdgeColor','none');
rectangle('Position',[120 0 15 mapH],'FaceColor',aisleColor,'EdgeColor','none');
rectangle('Position',[185 0 35 mapH],'FaceColor',aisleColor,'EdgeColor','none');

%% ================== ZONES ==================
Zones = {
    [10  65 50 40], 'Zone 1', [0.8 0.9 1.0];
    [75  65 45 40], 'Zone 2', [1.0 0.85 0.6];
    [135 65 50 40], 'Zone 3', [0.9 0.8 1.0];
    [10  10 50 40], 'Zone 4', [0.8 1.0 0.8];
    [75  10 45 40], 'Zone 5', [1.0 0.8 0.8];
    [135 10 50 40], 'Zone 6', [0.7 0.85 0.85];
};

for i = 1:6
    pos = Zones{i,1};
    rectangle('Position',pos,'FaceColor',Zones{i,3},'EdgeColor','k','LineWidth',1.2);
    text(pos(1)+pos(3)/2, pos(2)+pos(4)-4, upper(Zones{i,2}),...
         'FontWeight','bold','HorizontalAlignment','center');
end

%% ================== LORA ZONE NODE POSITIONS ==================
ZoneCenters = zeros(6,2);

for i = 1:6
    pos = Zones{i,1};
    ZoneCenters(i,:) = [pos(1)+pos(3)/2, pos(2)+pos(4)/2];
    
    % Optional: mark LoRa node
    plot(ZoneCenters(i,1), ZoneCenters(i,2), 'ks', ...
        'MarkerFaceColor','y', 'MarkerSize',6);
end


%% ================== RACKS ==================
rackColor = [1 1 1];

for i = 1:size(Zones,1)
    pos = Zones{i,1};
    rackCount = 4;
    rackLength = pos(3) - 10;
    rackHeight = 4;
    spacing = (pos(4)-10)/rackCount;

    for r = 1:rackCount
        rx = pos(1) + 5;
        ry = pos(2) + pos(4) - 5 - r*spacing;
        rectangle('Position',[rx ry rackLength rackHeight],...
                  'FaceColor',rackColor,'EdgeColor','none');
    end
end

text(5,125,'Scale: 1 unit = 10 meters','FontSize',9);
text(5,120,'Grey = Walkways | Colored = Zones | White = Racks','FontSize',9);

%% ================== DRAGGABLE CART DOT (SAFE VERSION) ==================

% Initial cart position
cartPos = [195 35];

% Plot cart
cartDot = plot(cartPos(1), cartPos(2), 'ro', ...
    'Tag','CART', ...
    'MarkerFaceColor','r', ...
    'MarkerSize',10);


% Store cart handle and state in figure
fig = gcf;
setappdata(fig,'cartDot',cartDot);
setappdata(fig,'isDragging',false);

% Mouse callbacks (anonymous, scope-safe)
set(cartDot,'ButtonDownFcn', @(src,evt) setappdata(fig,'isDragging',true));
set(fig,'WindowButtonUpFcn', @(src,evt) setappdata(fig,'isDragging',false));
set(fig,'WindowButtonMotionFcn', @(src,evt) dragCart());


%% ================== ZONE ITEMS ==================
ZoneItems = {
    {'SOAP','SHAMPOO','SCRUBBER','SHOWER GEL'};
    {'BISCUITS','CHIPS','CAKES','CHOCOLATES'};
    {'TOMATO','POTATO','ONION','CARROT'};
    {'MOBILE','HEADPHONES','CHARGER','POWER BANK'};
    {'BEDSHEET','PILLOW','CURTAIN','BLANKET'};
    {'SHOES','SLIPPERS','SANDALS','SOCKS'};
};

%% ================== ITEM LABELS ==================
for i = 1:size(Zones,1)
    pos = Zones{i,1};
    spacing = (pos(4)-10)/4;

    for r = 1:4
        rx = pos(1) + pos(3)/2;
        ry = pos(2) + pos(4) - 5 - r*spacing + 2;
        text(rx, ry, ZoneItems{i}{r},...
            'FontSize',8,'FontWeight','bold',...
            'HorizontalAlignment','center');
    end
end

%% ================== RACK COORDINATE DATABASE ==================
RackDB = cell(6,4);
for z = 1:6
    pos = Zones{z,1};
    spacing = (pos(4)-10)/4;

    for r = 1:4
        ry = pos(2) + pos(4) - 5 - r*spacing;
        rectangle('Position',[pos(1)+5 ry pos(3)-10 4],...
            'FaceColor','w','EdgeColor','none');

        text(pos(1)+pos(3)/2, ry+2, ZoneItems{z}{r},...
            'FontSize',8,'FontWeight','bold','HorizontalAlignment','center');

        RackDB{z,r} = [pos(1)+pos(3)/2 ry+2];
    end
end


%% ================== INVISIBLE ROUTE GRID ==================
Routes.H = [5 21 28 36 57 76 83 91 110];
Routes.V = [5 67 127 195];

RackAccess = cell(6,4);
for z = 1:6
    for r = 1:4
        rack = RackDB{z,r};
        [~,iy] = min(abs(Routes.H - rack(2)));
        RackAccess{z,r} = [rack(1) Routes.H(iy)];
    end
end
%% ================== RACK ACCESS POINTS ==================
RackAccess = cell(6,4);

for z = 1:6
    for r = 1:4
        rack = RackDB{z,r};

        % Snap rack to nearest horizontal route
        [~,iy] = min(abs(Routes.H - rack(2)));
        RackAccess{z,r} = [rack(1) Routes.H(iy)];
    end
end

%% ================== GUI ==================
figure('Name','Zone & Item Selection','Position',[300 120 360 460]);

uicontrol('Style','text','Position',[60 420 240 25],...
    'String','ZONE & ITEM SELECTION','FontWeight','bold');

zoneDropdown = uicontrol('Style','popupmenu',...
    'Position',[80 380 200 30],...
    'String',{'ZONE 1','ZONE 2','ZONE 3','ZONE 4','ZONE 5','ZONE 6'},...
    'Callback',@updateItemList);

itemList = uicontrol('Style','listbox',...
    'Position',[60 220 240 140],...
    'Max',10,'Min',0,...
    'String',ZoneItems{1},...
    'Callback',@updateSelectedItems);

uicontrol('Style','text','Position',[60 185 240 20],...
    'String','SELECTED ITEMS','FontWeight','bold');

selectedBox = uicontrol('Style','listbox',...
    'Position',[60 90 240 90],...
    'String',{},'Max',10,'Min',0);

uicontrol('Style','pushbutton','Position',[110 45 140 30],...
    'String','START','FontWeight','bold',...
    'Callback',@startSelection);

uicontrol('Style','pushbutton','Position',[110 10 140 30],...
    'String','❌ REMOVE ITEM','FontWeight','bold',...
    'Callback',@removeSelectedItem);

%% ================== LORA + UWB DISTANCE GUI (CLEAN UI) ==================
distFig = figure('Name','LoRa & UWB Distance Monitor', ...
    'Position',[950 200 320 380], ...
    'Color','w');

% ---- LORA TITLE ----
uicontrol(distFig,'Style','text', ...
    'Position',[40 340 240 25], ...
    'String','CART → ZONE DISTANCE (LoRa)', ...
    'FontWeight','bold', ...
    'FontSize',10);

distText = gobjects(6,1);
for i = 1:6
    distText(i) = uicontrol(distFig,'Style','text', ...
        'Position',[60 340-30*i 200 22], ...
        'HorizontalAlignment','left', ...
        'String',sprintf('Zone %d : -- m', i), ...
        'FontSize',10);
end

% ---- SEPARATOR LINE ----
uicontrol(distFig,'Style','text', ...
    'Position',[40 140 240 2], ...
    'BackgroundColor',[0.7 0.7 0.7], ...
    'String','');

% ---- UWB TITLE ----
uicontrol(distFig,'Style','text', ...
    'Position',[40 110 240 25], ...
    'String','UWB RACK DISTANCE', ...
    'FontWeight','bold', ...
    'FontSize',10);

uwbText = gobjects(4,1);
for r = 1:4
    uwbText(r) = uicontrol(distFig,'Style','text', ...
        'Position',[60 110-25*r 200 22], ...
        'HorizontalAlignment','left', ...
        'String',sprintf('Rack %d : -- m', r), ...
        'FontSize',9);
end

% ---- STORE HANDLES ----
setappdata(distFig,'distText',distText);
setappdata(distFig,'uwbText',uwbText);
setappdata(distFig,'ZoneCenters',ZoneCenters);
setappdata(distFig,'RackDB',RackDB);


%% ================== CALLBACKS ==================
function updateItemList(src,~)
    ZoneItems = evalin('base','ZoneItems');
    set(findobj('Style','listbox','Position',[60 220 240 140]),...
        'String',ZoneItems{src.Value},'Value',[]);
end

function updateSelectedItems(src,~)
    global SelectedItems;
    items = get(src,'String');
    idx = get(src,'Value');
    if isempty(idx), return; end
    SelectedItems = unique([SelectedItems; items(idx)]);
    set(findobj('Style','listbox','Position',[60 90 240 90]),...
        'String',SelectedItems);
end

function removeSelectedItem(~,~)
    global SelectedItems;
    box = findobj('Style','listbox','Position',[60 90 240 90]);
    idx = get(box,'Value');
    if isempty(idx), return; end
    SelectedItems(idx) = [];
    set(box,'String',SelectedItems,'Value',[]);
end

function startSelection(~,~)
    global SelectedItems RackAccess mallFig;

    if isempty(SelectedItems)
        errordlg('Select at least one item');
        return;
    end

    ZoneItems = evalin('base','ZoneItems');

    % ---- ENTRY POINT (ON GRID) ----
    startPos = [195 35];

    % ---- GET TARGET RACK ACCESS POINTS ----
    Targets = getTargetNodes(SelectedItems, ZoneItems, RackAccess);

    % ---- ORDER TARGETS (SHORTEST GRID ROUTE) ----
    orderedTargets = orderTargets(startPos, Targets);

    % ---- DRAW ROUTE ----
    figure(mallFig); hold on;
    delete(findobj(gca,'Tag','ROUTE'));  % remove old routes

    V_routes = [5 67 127 195];   % vertical aisles
    drawRoute(startPos, orderedTargets, V_routes);

end


%% ================== DEBUG: SHOW INVISIBLE ROUTES ON MAP ==================
debugRoutes = true;   % turn OFF later by setting false

if debugRoutes
    figure(mallFig); hold on;

    % Horizontal routes (exact as image)
    H_routes = [5 21 28 36 57 76 83 91 110];

    for y = H_routes
    plot([5 195], [y y], 'k', 'LineWidth', 1);
    end

    % Vertical routes (exact as image)
    V_routes = [5 67 127 195];

    for x = V_routes
    plot([x x], [5 110], 'k', 'LineWidth', 1);
    end
end
%% ===================DRAGGING====================
function dragCart()
    fig = gcf;

    if ~isappdata(fig,'isDragging') || ~getappdata(fig,'isDragging')
        return;
    end

    cartDot = getappdata(fig,'cartDot');
    if isempty(cartDot) || ~isvalid(cartDot)
        return;
    end

    ax = gca;
    cp = get(ax,'CurrentPoint');

    x = cp(1,1);
    y = cp(1,2);

    % Keep inside map limits
    x = max(0, min(220, x));
    y = max(0, min(115, y));

    % Move cart
    set(cartDot,'XData',x,'YData',y);

    %% ========== LORA DISTANCE UPDATE ==========
    distFig = findobj('Name','LoRa & UWB Distance Monitor');
    if isempty(distFig)
        drawnow limitrate;
        return;
    end

    ZoneCenters = getappdata(distFig,'ZoneCenters');
    distText    = getappdata(distFig,'distText');

    zoneDist = zeros(6,1);
    for i = 1:6
        zoneDist(i) = sqrt((x-ZoneCenters(i,1))^2 + (y-ZoneCenters(i,2))^2);
        set(distText(i),'String', ...
            sprintf('Zone %d : %.2f m', i, zoneDist(i)));
    end

    %% ========== UWB DISTANCE UPDATE ==========
    uwbText = getappdata(distFig,'uwbText');
    RackDB  = getappdata(distFig,'RackDB');

    % Find active zone (within 30 m)
    activeZone = find(zoneDist <= 30, 1);

    if isempty(activeZone)
        % UWB inactive
        for r = 1:4
            set(uwbText(r),'String',sprintf('Rack %d : -- m', r));
        end
    else
        % UWB active → rack-level distances
        for r = 1:4
            rack = RackDB{activeZone,r};
            d = sqrt((x-rack(1))^2 + (y-rack(2))^2);
            set(uwbText(r),'String', ...
                sprintf('Zone %d Rack %d : %.2f m', activeZone, r, d));
        end
    end

    drawnow limitrate;
end
% ================= ROUTE PLANNING FUNCTIONS =================

function Targets = getTargetNodes(SelectedItems, ZoneItems, RackAccess)
    Targets = [];

    for i = 1:length(SelectedItems)
        for z = 1:6
            r = find(strcmpi(ZoneItems{z}, SelectedItems{i}));
            if ~isempty(r)
                Targets = [Targets; RackAccess{z,r}];
            end
        end
    end
end


function orderedTargets = orderTargets(startPos, Targets)
    orderedTargets = [];
    current = startPos;

    while ~isempty(Targets)
        d = abs(Targets(:,1)-current(1)) + abs(Targets(:,2)-current(2));
        [~,idx] = min(d);

        orderedTargets = [orderedTargets; Targets(idx,:)];
        current = Targets(idx,:);
        Targets(idx,:) = [];
    end
end


function drawRoute(startPos, orderedTargets, V_routes)
    current = startPos;

    for i = 1:size(orderedTargets,1)
        target = orderedTargets(i,:);

        % ---- choose nearest vertical aisle ----
        [~,ix] = min(abs(V_routes - current(1)));
        aisleX = V_routes(ix);

        % 1) Move horizontally to aisle (exit rack)
        plot([current(1) aisleX], ...
             [current(2) current(2)], ...
             'b-', 'LineWidth',3,'Tag','ROUTE');

        % 2) Move vertically on aisle
        plot([aisleX aisleX], ...
             [current(2) target(2)], ...
             'b-', 'LineWidth',3,'Tag','ROUTE');

        % 3) Move horizontally from aisle to target rack
        plot([aisleX target(1)], ...
             [target(2) target(2)], ...
             'b-', 'LineWidth',3,'Tag','ROUTE');

        % Mark destination
        plot(target(1), target(2), 'go', ...
            'MarkerFaceColor','g', 'MarkerSize',8);

        current = target;
    end
end
