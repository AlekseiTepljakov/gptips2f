%GPDEMO1 GPTIPS 2 demo of simple symbolic regression on Koza's quartic polynomial.
%
%   Demonstrates simple (naive) symbolic regression and some post run
%   analysis functions such as SUMMARY, RUNTREE and GPPRETTY to simplify
%   expressions if the Symbolic Math Toolbox is present. Also shows the use
%   of DRAWTREES to visualise the tree structure of GPTIPS individuals.
%
%   (c) Dominic Searson 2009-2015
%
%   GPTIPS 2
%
%   See also GPDEMO1_CONFIG, QUARTIC_FITFUN, GPDEMO2, GPDEMO3, GPDEMO4,
%   SUMMARY, RUNTREE, GPPRETTY

clc;
disp('GPTIPS 2 Demo 1: naive symbolic regression');
disp('------------------------------------------');
disp('Naive symbolic regression on 20 data points genenerated by the');
disp('quartic polynomial y=x+x^2+x^3+x^4 in the range -1 < x < 1');
disp('The GP run configuration file is gpdemo1_config.m');
disp(' ');
disp('In this example, the direct output of a single evolved GP tree is used to');
disp('model the data generated by the quartic polynomial.');
disp('The function nodes used are TIMES, MINUS, PLUS and RDIVIDE.');
disp('The only terminal node used is the input x and trees are constrained');
disp('to have a maximum depth of 12.');
disp(' ');
disp('A population size of 50 is run for 100 generations.');
disp('The ''fitness'' is sum of absolute differences between the actual and');
disp('the predicted y values and GPTIPS tries to minimise this.');
disp(' ');

disp('First, call GPTIPS using the configuration in gpdemo1_config.m');
disp('using:');
disp('>>gp=rungp(@gpdemo1_config);');
disp('Press a key to continue');
disp(' ');
pause;
gp=rungp(@gpdemo1_config);

disp('Next, plot summary information of run using:');
disp('>>summary(gp)');
disp('Press a key to continue');
disp(' ');
pause;
summary(gp,false);

disp('Run the best model of the run on the fitness function using:');
disp('>>runtree(gp,''best'');');
disp('Press a key to continue');
disp(' ');
pause;
runtree(gp,'best');

disp(' ');
disp('The best model of the run is stored in the field:');
disp('gp.results.best.eval_individual{1} :');
disp(' ');
disp( gp.results.best.eval_individual{1});
disp(' ');

disp(['This model has a tree depth of ' int2str( getdepth(gp.results.best.individual{1}))]);
disp(['It was found at generation ' int2str(gp.results.best.foundatgen)]);
disp(['and has fitness ' num2str(gp.results.best.fitness)]);

%If Symbolic Math toolbox is present
if gp.info.toolbox.symbolic()
    
    disp(' ');
    disp('Using the symbolic math toolbox simplified versions of this');
    disp('expression can be found: ')
    disp('E.g. using the the GPPRETTY command on the best model: ');
    disp('>>gppretty(gp,''best'') ');
    disp('Press a key to continue');
    disp(' ');
    pause;
    gppretty(gp,'best');
    disp(' ');
    disp('If you are lucky then this is the quartic polynomial used to');
    disp('generate the data.');
    disp('NOTE: In general, it is unusual for GP to evolve the exact form');
    disp('of the generative function.');
end

disp(' ');
disp('Next, visualise the tree structure of the best model of the run:');
disp('>>drawtrees(gp,''best'');');
disp('Press a key to continue');
disp(' ');
pause;
drawtrees(gp,'best');