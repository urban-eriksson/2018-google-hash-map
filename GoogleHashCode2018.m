function GoogleHashCode2018()
%[R,C,F,N,B,T,rides] = read_file('a_example');
[R,C,F,N,B,T,rides] = read_file('b_should_be_easy');
%[R,C,F,N,B,T,rides] = read_file('c_no_hurry');
%[R,C,F,N,B,T,rides] = read_file('d_metropolis');
%[R,C,F,N,B,T,rides] = read_file('e_high_bonus');
[assignments,score] = run_simulation(rides,F,N,B,T);
disp(['Score: ' num2str(score)]);
write_file(assignments)

function [assignments,score] = run_simulation(rides, F, N, B, T)
vehicles = struct('r',repmat({0},1,F),'c',repmat({0},1,F),'busy_until',repmat({0},1,F));
assignments = cell(1,F);
ride_taken = false(1,N);
score = 0;
t = 0;
sortix = 1;
while t < T
    v = sortix(1);
    t = vehicles(v).busy_until;
    best_ride.fom = 0;
    for r = 1:N
        if ~ride_taken(r)
            [fom, t_finish, points] = figure_of_merit(t,vehicles(v),rides(r),B);
            if fom > best_ride.fom
                best_ride.fom = fom;
                best_ride.index = r;
                best_ride.t_finish = t_finish;
                best_ride.points = points;
            end
        end
    end
    if best_ride.fom > 0
        ride_taken(best_ride.index) = true;
        vehicles(v).r = rides(best_ride.index).x;
        vehicles(v).c = rides(best_ride.index).y;
        vehicles(v).busy_until = best_ride.t_finish;
        score = score + best_ride.points;
    else
        vehicles(v).busy_until = 1e9;
    end
    [~,sortix] = sort([vehicles.busy_until]);
end    
disp('hej')

function [fom, t_finish , points] = figure_of_merit(t, vehicle, ride, B)
dist_to_start = abs(vehicle.r - ride.a) + abs(vehicle.c - ride.b);
dist_of_ride =  abs(ride.a - ride.x) + abs(ride.b - ride.y);
points = dist_of_ride;
if t + dist_to_start <= ride.s
    points = points + B;
    t_finish = ride.s + dist_of_ride;
else
    t_finish = t + dist_to_start + dist_of_ride;
end
fom = points / (t_finish - t);

function [R,C,F,N,B,T,rides] = read_file(fname)
fid = fopen([fname '.in']);
q = str2num(fgetl(fid));
R = q(1);C = q(2);F = q(3);N = q(4);B = q(5);T = q(6);
rides=[];
while ~feof(fid)
    q = str2num(fgetl(fid));
    rides = [rides struct('a',q(1),'b',q(2),'x',q(3),'y',q(4),'s',q(5),'f',q(6))];
end

function write_file(assignments)
fid = fopen('submission.txt','w');
for j = 1:length(assignments)
    if isempty(assignments{j})
        fprintf(fid,'%s',['0' char([13 10])]);
    else
        s = sprintf('%i ',assignments{j});
        fprintf(fid,'%s',[num2str(length(assignments{j})) ' ' s(1:end-1) char([13 10])]);
    end
end
fclose(fid);

