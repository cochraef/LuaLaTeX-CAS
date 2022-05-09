defaultpen(fontsize(10 pt));
settings.prc = false;


    import settings;
    settings.tex = "xelatex";
    import graph;
    import contour;
    size(7cm,6cm,IgnoreAspect);

    real G(pair uv){
        real x=uv.x; real y=uv.y;
        return  (((x ^ 2) + (x * y)) + (y ^ 2)) ;
    }
    real L(pair uv){
        real x=uv.x; real y=uv.y;
        return ((((3 * (x ^ 2)) + (4 * x * y)) * (x + (2 * y))) - ((-1 + (2 * (x ^ 2))) * ((2 * x) + y)));
    }

    real[] gvals={1};
    real[] lvals={0};

    guide[][] con = contour(G,(-2,-2),(2,2),gvals);
    guide[][] lag = contour(L,(-2,-2),(2,2),lvals);

    limits((-2.5,-2.5),(2.5,2.5));

    draw(con,blue+1);
    draw(lag,red+1);

    xaxis(Label("$x$",align=S),LeftRight,LeftTicks(Label(align=right)));
    yaxis(Label("$y$",align=W),BottomTop,RightTicks(Label(align=left)));
