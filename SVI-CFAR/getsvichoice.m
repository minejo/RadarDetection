function [AB,go,B,A,S] = getsvichoice( choice )
c1=0;
c2=0;
c3=0;
c4=0;
c5=0;

for i=1:length(choice)
    if(choice(i)==1)
        c1=c1+1;
    end
    if(choice(i)==2)
        c2=c2+1;
    end
    if(choice(i)==3)
        c3=c3+1;
    end
    if(choice(i)==4)
        c4=c4+1;
    end
    if(choice(i)==5)
        c5=c5+1;
    end    
end

AB=c1/length(choice);
go=c2/length(choice);
B=c3/length(choice);
A=c4/length(choice);
S=c5/length(choice);
end

