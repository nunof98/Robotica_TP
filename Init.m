% %myev3 = legoev3('bt','0016538151B2');
% myev3 = legoev3('USB');
% mygyrosensor = gyroSensor(myev3,2);
% motorY = motor(myev3,'B');
% motorX = motor(myev3,'C');
% motorGripper = motor(myev3,'A');
% sensor1 = touchSensor(myev3,1);
% sensor2 = touchSensor(myev3,3);
% 
% beep(myev3);
%% Init comunnication between matlab and lego EV3

%initCommunication( );

%% calibrate gripper
clearLCD(myev3);
writeLCD(myev3, 'PLEASE WAIT', 5, 8);
writeStatusLight(myev3, 'orange', 'pulsing');

pause(2);
motorGripper.Speed = -40;
start(motorGripper);
pause(1);
motorGripper.Speed = 50;
pause(2.5);
motorGripper.Speed = 0;
resetRotation(motorGripper);
target = -100;
while(readRotation(motorGripper) > target)
    motorGripper.Speed = -35;
    start(motorGripper);
end
motorGripper.Speed = 0;
resetRotation(motorGripper);

%% Proceed to find zero position
%
%Verify Z position of the gripper
while (readTouch(sensor2) ~= 1)
    motorY.Speed = -30;
    start(motorY); 
end
motorY.Speed = 0;
readRotation(motorY)
%%
% Calibrate
%Verify XY position of the gripper
while(readTouch(sensor1)~=1)
    motorX.Speed =30;
    start(motorX);
end
motorX.Speed = 0;
resetRotation(motorX);

target = -370;
while(readRotation(motorX) > target)
    motorX.Speed = -10;
    start(motorX);
end
motorX.Speed = 0;
resetRotation(motorX);
%%
%reset angle
resetRotationAngle(mygyrosensor);
readRotationAngle(mygyrosensor);
%play sound
playTone(myev3,412.0,0.5,10);
pause(0.5);
playTone(myev3,550.0,0.75,50);
pause(0.75);
playTone(myev3,925.0,0.25,10);

clearLCD(myev3);
for i=1:3
    writeLCD(myev3, 'READY', 5, 8);
    pause(0.25);
    clearLCD(myev3);
    pause(0.25);
end
writeLCD(myev3, 'READY', 5, 8);
writeStatusLight(myev3,'green','solid');
