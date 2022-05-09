defaultpen(fontsize(10 pt));
settings.prc = false;


    import settings;
    settings.tex = "xelatex";
    import graph;
    import contour;
    size(6cm,5cm,IgnoreAspect);

    real f(real x){
        return  (2 * x * ((1 + (x ^ 2)) ^ -2) * sin(((1 + (x ^ 2)) ^ -1))) ;
        }
    path q = graph(f,0,2,operator..);

    draw(q,blue);

    xaxis("$x$",LeftRight,LeftTicks);
    yaxis("$y$",BottomTop,RightTicks);
