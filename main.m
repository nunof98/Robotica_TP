close all; clc;
%start timer
tic
%% calculate dimensions
% zona1=[1053.60372618115,277.526265987993];               
% zona2=[1361.43009044243,191.254613786360];
% zona3=[1376.38416276981,829.911430429532];
% 
% px2mm_x = 99 /(zona2(1,1)- zona1(1,1))
% px2mm_y = 280 / (zona3(1,2)- zona2(1,2))
% x_relation = (1920 * px2mm_x);  %resize of the image in x
% y_relation= (1080 * px2mm_y);   %resize of the image in y
% move_x = -(zona2(1,1) * x_relation)/1920
% move_y = -((zona2(1,2) + ((zona3(1,2)- zona2(1,2))/2))*y_relation)/1080


%% Connect to Lego EV3
%  myev3 = legoev3('USB');
%  mygyrosensor = gyroSensor(myev3,2);
% 
%  motorY = motor(myev3,'B');
%  motorX = motor(myev3,'C');
%  motorGripper = motor(myev3,'A');
%  sensor1 = touchSensor(myev3,1);
%  sensor2 = touchSensor(myev3,3);
%  myarduino = arduino('COM6','Uno');
% 
%  beep(myev3);

%%
configurePin(myarduino, 'D12')
configurePin(myarduino,'D3','pullup');
while (1)
    readDigitalPin(myarduino,'D3')
    if(readDigitalPin(myarduino,'D3')~=0)
      writeDigitalPin(myarduino, 'D12', 1)
    else
    writeDigitalPin(myarduino, 'D12', 0)       
    %% Adquire image
   
    %Colocar o 'ip server fornecido pela aplicação','o user', 'a password' 
    cam = ipcam('http://192.168.137.176:8080/video','mia3', '1234');
    im_RGB = snapshot(cam);


    %create figure
    %figure(1);
    %% Segment objects
    %define gripper coordinates
    x_gripper = 1371;
    y_gripper = 504;

    %zone of interest limits
    x0 = 860;
    x1 = 1120;
    y0 = 445;
    y1 = 610;


    %create zone of interest
    c = [x0 x1 x1 x0];
    r = [y0 y0 y1 y1];
    BW = roipoly(im_RGB, c, r);

    %overlap mask of original image
    im_box = MaskOperation(im_RGB, BW);

    %segment image
    im_object = SegmentObject(im_box, 220/255);

    %fills holes in image
    im_object_filled = imfill(im_object, 'holes');

    % %show images
    % subplot(2,3,1); imshow(im_RGB); title('RGB image');
    % %show what object was selected by drawing its perimeter
    % hold on
    % contorno = bwboundaries(im_object);
    % b = contorno{1};                            % objeto com area maior
    % plot(b(:,2),b(:,1),'r','LineWidth',2);      % desenha contorno
    % hold off
    % 
    % subplot(2,3,4); imshow(im_object); title('Object image');
    % subplot(2,3,5); imshow(im_object_filled); title('Object filled image');

    %% Mask operation
    im_RGB_mask = MaskOperation(im_RGB, im_object_filled);

    % %show image
    % subplot(2,3,6); imshow(im_RGB_mask); title('RGB mask image');

    %% Get colour

    %invert image
    inverted = imcomplement(im_RGB_mask);

    %figure(2);
    [im_object, x_pixel, y_pixel] = SegmentObject(inverted, 26/255);

    %mask operation
    im_RGB_mask2 = MaskOperation(im_RGB_mask, im_object);

    %get central pixel colour
    [im_Pixel, H, S, V] = GetPixelColour(im_RGB_mask2, x_pixel, y_pixel);

    % %show images
    % subplot(2, 3, 1); imshow(im_RGB_mask); title('RGB image');
    % %show what object was selected by drawing its perimeter
    hold on
    contorno = bwboundaries(im_object);
    b = contorno{1};                            % objeto com area maior
    plot(b(:,2),b(:,1),'r','LineWidth',2);      % desenha contorno
    hold off

%     subplot(2, 3, 2); imshow(inverted); title('Inverted image');
%     subplot(2, 3, 4); imshow(im_object); title('Object Binary');
%     subplot(2, 3, 5); imshow(im_RGB_mask2); title('Object RGB');
%     subplot(2, 3, 6); imshow(im_Pixel); title('Pixel image');

    %get object shape
    %shape_object = GetShape(im_RGB_mask2);

    %% Find objects with same color

    %segment image by colour
    im_RGB_segmented = ColorSegment(im_RGB, H, S ,V);
    %show image
    %figure(3);
    % subplot(2, 3, 1); imshow(im_RGB_segmented); title('RGB image');

    %find other object with the same colour
    [im_ZONE, x_zone, y_zone, numberObjects] = SegmentObject(im_RGB_segmented);

    %fills holes in image
    im_ZONE_filled = imfill(im_ZONE, 'holes');

    im_ZONE_mask = MaskOperation(im_RGB, im_ZONE_filled);

    %get zone shape
    %shape_zone = GetShape(im_ZONE_mask);

    % % show image
    % subplot(2, 3, 4); imshow(im_ZONE_filled); title('Zone Binary');
    % subplot(2, 3, 5); imshow(im_ZONE_mask); title('Zone RGB');
    %  subplot(2, 3, 6); imshow(im_RGB); title('RGB image');
    % % % show what object was selected by drawing its perimeter
    % hold on
    % contorno = bwboundaries(im_ZONE);
    % b = contorno{1};                            % objeto com area maior
    % plot(b(:,2),b(:,1),'r','LineWidth',2);      % desenha contorno
    % text('position', int16([x_zone - 50 y_zone]), 'fontsize', 10, 'color', 'white')

    %% Robo's treatment
    px2mm_x = 0.3216;                %relation between pixel and mm in x
    px2mm_y =   0.4384;                %relation between pixel and mm in x
    x_relation = (1920 * px2mm_x);  %resize of the image in x
    y_relation= (1080 * px2mm_y);   %resize of the image in y
    im_RGB = imresize(im_RGB, [y_relation x_relation]);
    move_x =  -437.8494;                %shift image in x
    move_y = -223.8499;                 %shift image in y

    L1 = Link([0 100 50 deg2rad(90)]);
    Laux = Link([0 0 0 -deg2rad(90)]);
    L2 = Link([0 50 -190 0]);
    Robo = SerialLink([L1 Laux L2]);

    variaveis = [deg2rad(0) deg2rad(0) 0];
    % figure(7)
    % plot(Robo, variaveis)
    % XMIN = -700;
    % XMAX = 766;
    % YMIN =-700;
    % YMAX =431;
    % ZMIN = 0;
    % ZMAX =300;
    % axis([XMIN XMAX YMIN YMAX ZMIN ZMAX]);
    % hold on
    % 
    % g = hgtransform;
    % image(im_RGB, 'Parent', g)
    % axis ij
    % g.Matrix = makehgtform('translate',[move_x move_y 0]);
    % hold off
    % fkine(Robo,variaveis)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % every degree match to 3,222222 degree on motor's encoder %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %reset motors
    resetRotation(motorX);
    resetRotation(motorY);
    resetRotation(motorGripper);

    %xyz coordinates
    x_desejado = 101.7;    %posição com braço em baixo 101.7
    y_desejado = 0;        %posição com braço em baixo 0
    z_desejado = -89.54;   %posição com braço em baixo -89.54
%      x_desejado= -88.3;      %posição com braço em baixo 101.7
%      y_desejado= 0;          %posição com braço em baixo 0
%      z_desejado= -39.54;     %posição com braço em baixo -89.54


    T = [1 0 0 x_desejado; 0 1 0 y_desejado; 0 0 1 z_desejado; 0 0 0 1];
    position_motorX = double(readRotation(motorX)) / 3.2222222;
    position_motorY = double(readRotation(motorY)) / 3.2222222;
    Pose_atual = [deg2rad(position_motorX) deg2rad(position_motorY) 0];
    Novos_valores_das_juntas = Robo.ikine(T, Pose_atual, 'mask', [1 1 1 0 0 0], 'ilimit', 1000, 'tol', 1);

    %plot(Robo, Novos_valores_das_juntas);
    %fkine(Robo, Novos_valores_das_juntas);
    Novos_valores_das_juntas = rad2deg(Novos_valores_das_juntas);
    %Calacula valor a atribuir á primeira rotula
    valor_da_rotula1 = (Novos_valores_das_juntas(1,1) + Novos_valores_das_juntas(1,3)) * 3.2222222;
    %Calacula valor a atribuir á segunda rotula
    valor_da_rotula2 = Novos_valores_das_juntas(1,2) * 3.2222222;

    %Posição em z
    if(valor_da_rotula2 > readRotation(motorY))
        while(readRotation(motorY) < valor_da_rotula2)
            motorY.Speed = ((valor_da_rotula2 - double(readRotation(motorY))) / 360) * 300;
            start(motorY);
        end
        readRotation(motorY)
    else
        while(readRotation(motorY) > valor_da_rotula2)
            motorY.Speed = ((valor_da_rotula2 - double(readRotation(motorY))) / 360) * 300;
            start(motorY);
        end
        readRotation(motorY)
    end
    pause(0.5)
    
    %movimento de recolha da caixa
    resetRotation(motorGripper);
    target = 100.0;
    while(readRotation(motorGripper) < target)
        motorGripper.Speed = (target - double((readRotation(motorX))) / 360) * 350;
        start(motorGripper);
    end
    motorGripper.Speed = 0.001;
    readRotation(motorGripper)

    %colocar garra na posição superior   
    target = 0.0;
    while ((readRotation(motorY) > 8) && (readTouch(sensor2) ~= 1))
        motorY.Speed = ((target - double(readRotation(motorY))) / 360) * 300;
        start(motorY);
    end
    motorY.Speed = 0;
    readRotation(motorY)

    
    x_desejado = ( x_zone * px2mm_x) + move_x
    y_desejado = (y_zone *px2mm_y) + move_y
    z_desejado = 150;

    T = [1 0 0 x_desejado; 0 1 0 y_desejado; 0 0 1 z_desejado; 0 0 0 1];
    position_motorX = double(readRotation(motorX)) / 3.2222222;
    position_motorY = double(readRotation(motorY)) / 3.2222222;
    Pose_atual = [deg2rad(position_motorX) deg2rad(position_motorY) 0 ];
    Novos_valores_das_juntas = Robo.ikine(T, Pose_atual, 'mask', [1 1 1 0 0 0], 'ilimit', 1000, 'tol', 20);

    %plot(Robo,Novos_valores_das_juntas);
    %fkine(Robo, Novos_valores_das_juntas);
    Novos_valores_das_juntas = rad2deg(Novos_valores_das_juntas);
    valor_da_rotula1 = (Novos_valores_das_juntas(1,1) + Novos_valores_das_juntas(1,3)) * 3.2222222
    %Calacula valor a atribuir á segunda rotula
    valor_da_rotula2 = Novos_valores_das_juntas(1,2) * 3.2222222

    % Vai para a posição desejada em X / Y
    if(valor_da_rotula1 > readRotation(motorX))
        while(readRotation(motorX) < valor_da_rotula1)
            motorX.Speed = ((valor_da_rotula1 - double(readRotation(motorX))) / 360) * 450;
            start(motorX);
        end
        motorX.Speed = 0;
        readRotation(motorX)
    else
        while(readRotation(motorX) > valor_da_rotula1)
            motorX.Speed = ((valor_da_rotula1 - double(readRotation(motorX))) / 360) * 450;
            start(motorX);
        end
        readRotation(motorX)
        motorX.Speed = 0;
    end

    %Posição em z
    target = 330;
    if(target > readRotation(motorY))
        while(readRotation(motorY) < target)
            motorY.Speed = ((target - double(readRotation(motorY))) / 360) * 100;
            if(motorY.Speed < 15)
                motorY.Speed = 15; 
            end
            start(motorY);
        end
        motorY.Speed = 0;
        readRotation(motorY)
    else
        while(readRotation(motorY) > target)
            motorY.Speed = ((target - double(readRotation(motorY)))/360)*100;
            if(motorY.Speed > -10)
                motorY.Speed = -10; 
            end
            start(motorY);
        end
        motorY.Speed = 0;
        readRotation(motorY)
    end

    %Libertar caixa
    target = 0.0;
    while(readRotation(motorGripper) > target)
        motorGripper.Speed = ((target - double(readRotation(motorGripper))) / 360 * 260);
        if(motorGripper.Speed > -40)
           motorGripper.Speed = -40; 
        end
           start(motorGripper);
    end
    motorGripper.Speed = 0;
    readRotation(motorGripper)

    %Voltar à posição inicial 
    x_desejado= -140;
    y_desejado= 0;
    z_desejado= 150;

    T = [1 0 0 x_desejado; 0 1 0 y_desejado; 0 0 1 z_desejado; 0 0 0 1];
    position_motorX = double(readRotation(motorX)) / 3.2222222;
    position_motorY = double(readRotation(motorY)) / 3.2222222;
    Pose_atual = [deg2rad(position_motorX) deg2rad(position_motorY) 0];
    Novos_valores_das_juntas = Robo.ikine(T, Pose_atual, 'mask', [1 1 1 0 0 0], 'ilimit', 1000, 'tol', 20);

    %plot(Robo,Novos_valores_das_juntas);
    %fkine(Robo,Novos_valores_das_juntas);
    Novos_valores_das_juntas = rad2deg(Novos_valores_das_juntas);
    valor_da_rotula1 = (Novos_valores_das_juntas(1,1) + Novos_valores_das_juntas(1,3)) * 3.2222222;
    %Calacula valor a atribuir á segunda rotula
    valor_da_rotula2 = Novos_valores_das_juntas(1,2) * 3.222222;

    %colocar garra na posição superior   
    target = 0.0;
    while ((readRotation(motorY) > 8) && (readTouch(sensor2) ~= 1))
        motorY.Speed = ((target - double(readRotation(motorY)))/360)*400;
        start(motorY);
        if(motorY.Speed > -10)
            motorY.Speed = -10; 
        end
    end
    motorY.Speed = 0;
    readRotation(motorY);

    % Vai para a posição desejada em X / Y
    if(valor_da_rotula1 > readRotation(motorX))
        while(readRotation(motorX) < valor_da_rotula1)
            motorX.Speed = ((valor_da_rotula1 - double(readRotation(motorX))) / 360) * 210;
            start(motorX);
        end
        motorX.Speed = 0.1;
        readRotation(motorX)
    else
        while(readRotation(motorX) > valor_da_rotula1)
            motorX.Speed = ((valor_da_rotula1 - double(readRotation(motorX))) / 360) * 210;
            start(motorX);
        end
        readRotation(motorX)
        motorX.Speed = -0.0001;
    end

    %stop timer
    toc
   end
end

