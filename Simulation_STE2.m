% Simulation_STE2
clear all; close all; clc



%% Data & Parameters

load( 'vanHateren8_dataset.mat' )
X = double( permute( reshape( data, [ 192 * 128, 4212 ] ), [ 2, 1 ] ) );
X( X > 2000 ) = 2000;
X( X < 0 ) = 0;
X = X / 2000;
clear data

% load( 'pseudo_vanHateren8_dataset.mat' )
% X = double( permute( reshape( data, [ 192 * 128, 5 ] ), [ 2, 1 ] ) );
% X( X > 2000 ) = 2000;
% X( X < 0 ) = 0;
% X = X / 2000;
% clear data

info_X_sX = [ 192, 128; 64, 64; 0, 4 ];

io_f = {};
io_f{ 1, 1 }{ 1, 1 } = transpose( [ 1 : 4096 ] );% input, bottom-up
io_f{ 1, 1 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, bottom-up
io_f{ 1, 2 }{ 1, 1 } = io_f{ 1, 1 }{ 1, 2 };% input, top-down
io_f{ 1, 2 }{ 1, 2 } = io_f{ 1, 1 }{ 1, 1 };% output, top-down
io_f{ 1, 3 }{ 1, 1 } = transpose( [ 1 : 64 ] );% input, recurrent
io_f{ 1, 3 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, recurrent
io_f{ 2, 1 }{ 1, 1 } = transpose( [ 1 : 64 ] );% input, bottom-up
io_f{ 2, 1 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, bottom-up
io_f{ 2, 2 }{ 1, 1 } = io_f{ 2, 1 }{ 1, 2 };% input, top-down
io_f{ 2, 2 }{ 1, 2 } = io_f{ 2, 1 }{ 1, 1 };% output, top-down
io_f{ 2, 3 }{ 1, 1 } = transpose( [ 1 : 64 ] );% input, recurrent
io_f{ 2, 3 }{ 1, 2 } = transpose( [ 1 : 64 ] );% output, recurrent

hl_f = {};
hl_f{ 1, 1 }{ 1, 1 } = [];% bottom-up
hl_f{ 1, 2 }{ 1, 1 } = [];% top-down
hl_f{ 1, 3 }{ 1, 1 } = [];% recurrent
hl_f{ 2, 1 }{ 1, 1 } = [];% bottom-up
hl_f{ 2, 2 }{ 1, 1 } = [];% top-down
hl_f{ 2, 3 }{ 1, 1 } = [];% recurrent

nH = size( io_f, 1 );
nZ = [];
for h = 1 : size( io_f, 1 )
    totalZ = [];
    for p = 1 : size( io_f{ h, 1 }, 1 )
        totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
    end; clear p
    nZ( h, 1 ) = length( unique( totalZ ) );
    clear totalZ
end; clear h

kWidth = nan( nH, 1 );
for h = 1 : nH
    kWidth( h, 1 ) = 0.1 * sqrt( nZ( h ) );
end; clear h

cType = { 'regular'; 'sparse' };

miniBatchSize = 100;
nPred = [ 4 * size( io_f, 1 ) + 1, 1 ];
nMaxIter = repmat( 10000, [ 5, 1 ] );

N_iter = 1;


%%
% 
% lambda = [ 0.01; 0.01 ];
% 
% results = {};
% for iter = 1 : N_iter
%     
%     tic
%     % [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter );
%     [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter, 'GPU' );
%     toc
%     
%     results{ iter, 1 } = W_f;
%     results{ iter, 2 } = b_f;
%     results{ iter, 3 } = LS;
%     save( 'Results_lambda_001_001.mat', 'results' )
%     disp( [ '# of iter. = ', num2str( iter ) ] )
%     clear W_f b_f LS
% end; clear iter
% 
% clear results
% 
% clear lambda
% 

%%
% 
% lambda = [ 5; 5 ];
% 
% results = {};
% for iter = 1 : N_iter
%     
%     tic
%     % [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter );
%     [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter, 'GPU' );
%     toc
%     
%     results{ iter, 1 } = W_f;
%     results{ iter, 2 } = b_f;
%     results{ iter, 3 } = LS;
%     save( 'Results_lambda_5_5.mat', 'results' )
%     disp( [ '# of iter. = ', num2str( iter ) ] )
%     clear W_f b_f LS
% end; clear iter
% 
% clear results
% 
% clear lambda
% 

%%
% 
% lambda = [ 1000; 1000 ];
% 
% results = {};
% for iter = 1 : N_iter
%     
%     tic
%     % [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter );
%     [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter, 'GPU' );
%     toc
%     
%     results{ iter, 1 } = W_f;
%     results{ iter, 2 } = b_f;
%     results{ iter, 3 } = LS;
%     save( 'Results_lambda_1000_1000.mat', 'results' )
%     disp( [ '# of iter. = ', num2str( iter ) ] )
%     clear W_f b_f LS
% end; clear iter
% 
% clear results
% 
% clear lambda
% 

%%
% 
% lambda = [ 5; 5 ];
% 
% results = {};
% for iter = 1 : N_iter
% 
%     load( 'Results_lambda_5_5.mat' )
%     W_f = results{ iter, 1 };
%     b_f = results{ iter, 2 };
%     LS = results{ iter, 3 };
%     
%     tic
%     % [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter );
%     % [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter, 'GPU' );
%     [ W_f, b_f, LS ] = RR_STE2_learn_sgm( X, info_X_sX, io_f, hl_f, lambda, kWidth, cType, miniBatchSize, nPred, nMaxIter, 'GPU', 'initial', W_f, b_f, LS );
%     toc
%     
%     results{ iter, 1 } = W_f;
%     results{ iter, 2 } = b_f;
%     results{ iter, 3 } = LS;
%     save( 'Results_lambda_5_5_rep10.mat', 'results' )
%     disp( [ '# of iter. = ', num2str( iter ) ] )
%     clear W_f b_f LS
% end; clear iter
% 
% clear results
% 
% clear lambda
% 

%% Shows, LS
% 
% % clear all; close all; clc
% 
% % load( 'Results_lambda_001_001.mat' )
% load( 'Results_lambda_5_5.mat' )
% % load( 'Results_lambda_1000_1000.mat' )
% % load( 'Results_lambda_5_5_rep10.mat' )
% 
% for iter = 1 : size( results, 1 )
% 
%     LS = results{ iter, 3 };
% 
%     figure
%     for k = 1 : 2
%         subplot( 1, 2, k )
%         plot( LS{ k, 1 } )
%     end; clear k
% 
%     clear LS
% 
% end; clear iter
% 
% clear results
% 
