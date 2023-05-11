Kp=1.2;
c=-0.3;
Ki=Kp*(-c);

Gc=zpk(c, 0, Kp);
Gp=zpk([], [-0.1, -10], 25);

open_loop = Gc*Gp;
figure
rlocus(open_loop);

close_loop = feedback(open_loop, 1, -1);
figure
step(close_loop);
