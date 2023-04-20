% 
clear all; close all; clc



%% Parameters

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


nZ = [];
for h = 1 : size( io_f, 1 )
    totalZ = [];
    for p = 1 : size( io_f{ h, 1 }, 1 )
        totalZ = [ totalZ; io_f{ h, 1 }{ p, 2 } ];
    end; clear p
    nZ( h, 1 ) = length( unique( totalZ ) );
    clear totalZ
end; clear h


%% Response for Bar with Noise
% % 
% % noiseRanges = 0.025 * 2 .^ [ 0 : 4 ];
% % N_iter = 300;
% % 
% % bar_img = {};
% % bar_width = 0.1;
% % ct_theta = 0;
% % for bar_theta = pi * [ 0 : 0.125 : 0.875 ]
% %     ct_theta = ct_theta + 1;
% %     bar_img{ ct_theta, 1 } = [];
% %     ct_shift = 0;
% %     for bar_shift = -2 : 0.1 : 2
% %         ct_shift = ct_shift + 1;
% % 
% %         img = zeros( 64, 64 );
% %         % img = 0.5 * ones( 64, 64 );
% %         [ X_grid, Y_grid ] = meshgrid( linspace( -2, 2, 64 ), linspace( -2, 2, 64 ) );
% %         XY_grid = [];
% %         XY_grid( :, :, 1 ) = X_grid;
% %         XY_grid( :, :, 2 ) = Y_grid;
% %         XY_grid = reshape( XY_grid, [ 64 * 64, 2 ] );
% %         XY_grid = [ cos( bar_theta ), -sin( bar_theta ); sin( bar_theta ), cos( bar_theta ) ] * transpose( XY_grid );
% %         XY_grid = transpose( XY_grid );
% %         XY_grid = reshape( XY_grid, [ 64, 64, 2 ] );
% %         img( XY_grid( :, :, 2 ) > -bar_width - bar_shift & XY_grid( :, :, 2 ) < bar_width - bar_shift ) = 1;
% %         clear X_grid Y_grid XY_grid
% % 
% %         bar_img{ ct_theta, 1 }( :, :, ct_shift ) = img;
% %         clear img
% % 
% %     end; clear bar_shift ct_shift
% % end; clear bar_theta ct_theta
% % clear bar_width
% % 
% % 
% % 
% % Z_1_static = cell( size( bar_img, 1 ), length( noiseRanges ), 2 );
% % Z_2_static = cell( size( bar_img, 1 ), length( noiseRanges ), 2 );
% % Z_1_moving = cell( size( bar_img, 1 ), length( noiseRanges ), 2 );
% % Z_2_moving = cell( size( bar_img, 1 ), length( noiseRanges ), 2 );
% % 
% % for fn = 1 : 2
% % 
% %     if fn == 1
% %         load( 'Results_lambda_5_5_Objects.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda_1000_1000_Objects.mat' )
% %     end
% % 
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% % 
% % 
% %     for r = 1 : size( bar_img, 1 )
% % 
% %         nPred = [ 4 * size( io_f, 1 ) + 1, 1 ];
% %         rX = {};
% %         for h = 1 : size( io_f, 1 )
% %             rX{ h, 1 } = 0 * ones( size( bar_img{ 1, 1 }, 3 ), nZ( h ) );
% %         end; clear h
% %         for noiseLevel = 1 : length( noiseRanges )
% %             for iter = 1 : 2 * N_iter
% %                 t_bar_img = bar_img{ r, 1 };
% %                 t_bar_img = t_bar_img + noiseRanges( noiseLevel ) * randn( size( t_bar_img ) );
% %                 t_bar_img( t_bar_img > 1 ) = 1;
% %                 t_bar_img( t_bar_img < 0 ) = 0;
% %                 sX = transpose( reshape( t_bar_img, [ 64 * 64, size( t_bar_img, 3 ) ] ) );
% %                 sX = repmat( sX, [ 1, 1, prod( nPred, 2 ) ] );
% %                 [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %                 t_Z = Z{ 1, 1 }( ( prod( nPred, 2 ) - 1 ) * size( bar_img{ 1, 1 }, 3 ) + [ 1 : size( bar_img{ 1, 1 }, 3 ) ], : );
% %                 Z_1_static{ r, noiseLevel, fn }( :, :, iter ) = single( t_Z( 21 + [ -4 : 4 ], :, : ) );
% %                 t_Z = Z{ 2, 1 }( ( prod( nPred, 2 ) - 1 ) * size( bar_img{ 1, 1 }, 3 ) + [ 1 : size( bar_img{ 1, 1 }, 3 ) ], : );
% %                 Z_2_static{ r, noiseLevel, fn }( :, :, iter ) = single( t_Z( 21 + [ -4 : 4 ], :, : ) );
% %             end; clear iter
% %         end; clear noiseLevel
% %         clear rX t_bar_img sX Z E t_Z
% % 
% %         rX = {};
% %         for h = 1 : size( io_f, 1 )
% %             rX{ h, 1 } = 0 * ones( 1, nZ( h ) );
% %         end; clear h
% %         for noiseLevel = 1 : length( noiseRanges )
% %             for iter = 1 : 2 * N_iter
% %                 t_bar_img = bar_img{ r, 1 };
% %                 t_bar_img = t_bar_img + noiseRanges( noiseLevel ) * randn( size( t_bar_img ) );
% %                 t_bar_img( t_bar_img > 1 ) = 1;
% %                 t_bar_img( t_bar_img < 0 ) = 0;
% %                 sX = transpose( reshape( t_bar_img, [ 64 * 64, size( t_bar_img, 3 ) ] ) );
% %                 sX = permute( sX, [ 3, 2, 1 ] );
% %                 [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %                 Z_1_moving{ r, noiseLevel, fn }( :, :, iter ) = single( Z{ 1, 1 }( 21 + [ -4 : 4 ], :, : ) );
% %                 Z_2_moving{ r, noiseLevel, fn }( :, :, iter ) = single( Z{ 2, 1 }( 21 + [ -4 : 4 ], :, : ) );
% %             end; clear iter
% %         end; clear noiseLevel
% %         clear rX t_bar_img sX Z E
% % 
% %         disp( [ num2str( r ), ' / ', num2str( size( bar_img, 1 ) ) ] )
% % 
% %     end; clear r
% % 
% %     clear results iter W_f b_f
% % 
% % end; clear fn
% % 
% % 
% % save( 'Final_Results_Response_Noisy_Bar_Object.mat', 'noiseRanges', 'N_iter', 'bar_img', 'Z_1_static', 'Z_2_static', 'Z_1_moving', 'Z_2_moving' )
% % 

%% Decoding accuracy
% %
% % load( 'Final_Results_Response_Noisy_Bar_Object.mat' )
% % 
% % 
% % accLoc_1_trans = zeros( 9, length( noiseRanges ), 2, 6 );
% % accLoc_2_trans = zeros( 9, length( noiseRanges ), 2, 6 );
% % 
% % for fn = 1 : 2
% %     for noiseLevel = 1 : length( noiseRanges )
% %         for r = 5%[ 5 : -1 : 1, 8 : -1 : 6 ]
% % 
% % 
% %             data_tr = NaN( 9 * N_iter, 64 );
% %             data_te = NaN( 9 * N_iter, 64 );
% %             idx_tr = NaN( 9 * N_iter, 1 );
% %             idx_te = NaN( 9 * N_iter, 1 );
% %             for iter = 1 : N_iter
% %                 data_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_1_static{ r, noiseLevel, fn }( :, :, iter );
% %                 data_te( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_1_moving{ r, noiseLevel, fn }( :, :, N_iter + iter );
% %                 idx_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %                 idx_te( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %             end; clear iter
% % 
% %             Mdl = fitcnb( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );% Naive Bayes
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 1 ) = accLoc_1_trans( :, noiseLevel, fn, 1 ) + transpose( accH );
% % 
% %             idx_out = classify( data_te, data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );% LDA
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 2 ) = accLoc_1_trans( :, noiseLevel, fn, 2 ) + transpose( accH );
% % 
% %             Mdl = fitcecoc( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );% SVM
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 3 ) = accLoc_1_trans( :, noiseLevel, fn, 3 ) + transpose( accH );
% % 
% %             Mdl = fitctree( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );% Decision Tree
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 4 ) = accLoc_1_trans( :, noiseLevel, fn, 4 ) + transpose( accH );
% %             
% %             Mdl = fitcensemble( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr, 'Method', 'Bag' );% Ensemble classifier
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 5 ) = accLoc_1_trans( :, noiseLevel, fn, 5 ) + transpose( accH );
% % 
% %             layers = [ ...
% %                 featureInputLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 32 )
% %                 reluLayer
% %                 fullyConnectedLayer( 16 )
% %                 reluLayer
% %                 fullyConnectedLayer( length( unique( idx_tr ) ) )
% %                 softmaxLayer
% %                 classificationLayer ];
% %             options = trainingOptions( 'sgdm' );
% %             net = trainNetwork( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), categorical( idx_tr ), layers, options );
% %             idx_out = predict( net, data_te );
% %             [ ~, idx_out ] = max( idx_out, [], 2 );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 6 ) = accLoc_1_trans( :, noiseLevel, fn, 6 ) + transpose( accH );
% % 
% %             clear data_tr data_te idx_tr idx_te idx_out acc accH
% % 
% % 
% %             data_tr = NaN( 9 * N_iter, 64 );
% %             data_te = NaN( 9 * N_iter, 64 );
% %             idx_tr = NaN( 9 * N_iter, 1 );
% %             idx_te = NaN( 9 * N_iter, 1 );
% %             for iter = 1 : N_iter
% %                 data_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_2_static{ r, noiseLevel, fn }( :, :, iter );
% %                 data_te( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_2_moving{ r, noiseLevel, fn }( :, :, N_iter + iter );
% %                 idx_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %                 idx_te( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %             end; clear iter
% % 
% %             Mdl = fitcnb( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 1 ) = accLoc_2_trans( :, noiseLevel, fn, 1 ) + transpose( accH );
% % 
% %             idx_out = classify( data_te, data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 2 ) = accLoc_2_trans( :, noiseLevel, fn, 2 ) + transpose( accH );
% % 
% %             Mdl = fitcecoc( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 3 ) = accLoc_2_trans( :, noiseLevel, fn, 3 ) + transpose( accH );
% % 
% %             Mdl = fitctree( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );% Decision Tree
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 4 ) = accLoc_2_trans( :, noiseLevel, fn, 4 ) + transpose( accH );
% % 
% %             Mdl = fitcensemble( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr, 'Method', 'Bag' );% Ensemble classifier
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 5 ) = accLoc_2_trans( :, noiseLevel, fn, 5 ) + transpose( accH );
% % 
% %             layers = [ ...
% %                 featureInputLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 32 )
% %                 reluLayer
% %                 fullyConnectedLayer( 16 )
% %                 reluLayer
% %                 fullyConnectedLayer( length( unique( idx_tr ) ) )
% %                 softmaxLayer
% %                 classificationLayer ];
% %             options = trainingOptions( 'sgdm' );
% %             net = trainNetwork( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), categorical( idx_tr ), layers, options );
% %             idx_out = predict( net, data_te );
% %             [ ~, idx_out ] = max( idx_out, [], 2 );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 6 ) = accLoc_2_trans( :, noiseLevel, fn, 6 ) + transpose( accH );
% % 
% %             clear data_tr data_te idx_tr idx_te idx_out acc accH
% % 
% % 
% %         end; clear r
% %         disp( [ '(', num2str( fn ), ', ', num2str( noiseLevel ), ') / (2, ', num2str( length( noiseRanges ) ), ')' ] )
% %     end; clear noiseLevel
% % end; clear fn
% % 
% % 
% % accDir_1_trans = zeros( 5, length( noiseRanges ), 2, 6 );
% % accDir_2_trans = zeros( 5, length( noiseRanges ), 2, 6 );
% % 
% % for fn = 1 : 2
% %     for noiseLevel = 1 : length( noiseRanges )
% % 
% % 
% %         data_tr = NaN( 8 * 3 * N_iter, 64 );
% %         data_te = NaN( 8 * 3 * N_iter, 64 );
% %         idx_tr = NaN( 8 * 3 * N_iter, 1 );
% %         idx_te = NaN( 8 * 3 * N_iter, 1 );
% %         ct_r = 0;
% %         for r = [ 5 : -1 : 1, 8 : -1 : 6 ]
% %             ct_r = ct_r + 1;
% %             for iter = 1 : N_iter
% %                 data_tr( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], : ) = Z_1_static{ r, noiseLevel, fn }( 5 + [ -1 : 1 ], :, iter );
% %                 data_te( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], : ) = Z_1_moving{ r, noiseLevel, fn }( 5 + [ -1 : 1 ], :, N_iter + iter );
% %                 idx_tr( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], 1 ) = ct_r;
% %                 idx_te( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], 1 ) = ct_r;
% %             end; clear iter
% %         end; clear r ct_r
% % 
% %         Mdl = fitcnb( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_1_trans( :, noiseLevel, fn, 1 ) = transpose( accH );
% % 
% %         idx_out = classify( data_te, data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_1_trans( :, noiseLevel, fn, 2 ) = transpose( accH );
% % 
% %         Mdl = fitcecoc( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_1_trans( :, noiseLevel, fn, 3 ) = transpose( accH );
% % 
% %         Mdl = fitctree( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_1_trans( :, noiseLevel, fn, 4 ) = transpose( accH );
% % 
% %         Mdl = fitcensemble( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr, 'Method', 'Bag' );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_1_trans( :, noiseLevel, fn, 5 ) = transpose( accH );
% % 
% %         layers = [ ...
% %             featureInputLayer( 64 )
% %             reluLayer
% %             fullyConnectedLayer( 64 )
% %             reluLayer
% %             fullyConnectedLayer( 32 )
% %             reluLayer
% %             fullyConnectedLayer( 16 )
% %             reluLayer
% %             fullyConnectedLayer( length( unique( idx_tr ) ) )
% %             softmaxLayer
% %             classificationLayer ];
% %         options = trainingOptions( 'sgdm' );
% %         net = trainNetwork( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), categorical( idx_tr ), layers, options );
% %         idx_out = predict( net, data_te );
% %         [ ~, idx_out ] = max( idx_out, [], 2 );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_1_trans( :, noiseLevel, fn, 6 ) = transpose( accH );
% % 
% %         clear data_tr data_te idx_tr idx_te idx_out acc accH
% % 
% % 
% %         data_tr = NaN( 8 * 3 * N_iter, 64 );
% %         data_te = NaN( 8 * 3 * N_iter, 64 );
% %         idx_tr = NaN( 8 * 3 * N_iter, 1 );
% %         idx_te = NaN( 8 * 3 * N_iter, 1 );
% %         ct_r = 0;
% %         for r = [ 5 : -1 : 1, 8 : -1 : 6 ]
% %             ct_r = ct_r + 1;
% %             for iter = 1 : N_iter
% %                 data_tr( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], : ) = Z_2_static{ r, noiseLevel, fn }( 5 + [ -1 : 1 ], :, iter );
% %                 data_te( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], : ) = Z_2_moving{ r, noiseLevel, fn }( 5 + [ -1 : 1 ], :, N_iter + iter );
% %                 idx_tr( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], 1 ) = ct_r;
% %                 idx_te( ( ct_r - 1 ) * 3 * N_iter + ( iter - 1 ) * 3 + [ 1 : 3 ], 1 ) = ct_r;
% %             end; clear iter
% %         end; clear r ct_r
% % 
% %         Mdl = fitcnb( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_2_trans( :, noiseLevel, fn, 1 ) = transpose( accH );
% % 
% %         idx_out = classify( data_te, data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_2_trans( :, noiseLevel, fn, 2 ) = transpose( accH );
% % 
% %         Mdl = fitcecoc( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_2_trans( :, noiseLevel, fn, 3 ) = transpose( accH );
% % 
% %         Mdl = fitctree( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_2_trans( :, noiseLevel, fn, 4 ) = transpose( accH );
% % 
% %         Mdl = fitcensemble( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr, 'Method', 'Bag' );
% %         idx_out = predict( Mdl, data_te );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_2_trans( :, noiseLevel, fn, 5 ) = transpose( accH );
% % 
% %         layers = [ ...
% %             featureInputLayer( 64 )
% %             reluLayer
% %             fullyConnectedLayer( 64 )
% %             reluLayer
% %             fullyConnectedLayer( 32 )
% %             reluLayer
% %             fullyConnectedLayer( 16 )
% %             reluLayer
% %             fullyConnectedLayer( length( unique( idx_tr ) ) )
% %             softmaxLayer
% %             classificationLayer ];
% %         options = trainingOptions( 'sgdm' );
% %         net = trainNetwork( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), categorical( idx_tr ), layers, options );
% %         idx_out = predict( net, data_te );
% %         [ ~, idx_out ] = max( idx_out, [], 2 );
% %         acc = abs( angle( exp( 1i * ( ( pi * ( idx_out - 1 ) / 4 ) - ( pi * ( idx_te - 1 ) / 4 ) ) ) ) );
% %         accH = histcounts( acc, pi * [ -0.5 : 1 : 4.5 ] / 4 );
% %         accDir_2_trans( :, noiseLevel, fn, 6 ) = transpose( accH );
% % 
% %         clear data_tr data_te idx_tr idx_te idx_out acc accH
% % 
% % 
% %         disp( [ '(', num2str( fn ), ', ', num2str( noiseLevel ), ') / (2, ', num2str( length( noiseRanges ) ), ')' ] )
% %     end; clear noiseLevel
% % end; clear fn
% % 
% % 
% % save( 'Final_Results_Decoding_Accuracy_Bar_Object.mat', 'noiseRanges', 'accLoc_1_trans', 'accLoc_2_trans', 'accDir_1_trans', 'accDir_2_trans' )
% % 
% % 
% load( 'Final_Results_Decoding_Accuracy_Bar_Object.mat' )
% 
% 
% colors = [ 1, 0, 1; 0, 0, 1 ];
% lw = 1;
% 
% 
% chanceLevel = 1 / 9;
% 
% figure( 'position', [ 100, 100, 450, 250 ] )
% subplot( 1, 2, 1 )
% hold on
% for nCoding = 1 : 2
%     nClassifier = 1;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '-o', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 2;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--s', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 3;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--d', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 4;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--^', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 5;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--v', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 6;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), ':+', 'color', colors( nCoding, : ), 'linewidth', lw )
%     clear nClassifier DA
% end; clear nCoding
% plot( [ noiseRanges( 1 ), noiseRanges( end ) ], chanceLevel * [ 1, 1 ], '-.k', 'linewidth', lw )
% set( gca, 'xlim', [ 0, 0.45 ], 'ylim', [ 0, 1.1 ] )
% ylabel( 'Position decoding accuracy' )
% xlabel( 'Noise level' )
% title( 'Lower' )
% subplot( 1, 2, 2 )
% hold on
% for nCoding = 1 : 2
%     nClassifier = 1;
%     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '-o', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 2;
%     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--s', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 3;
%     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--d', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 4;
%     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--^', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 5;
%     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--v', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 6;
%     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), ':+', 'color', colors( nCoding, : ), 'linewidth', lw )
%     clear nClassifier DA
% end; clear nCoding
% plot( [ noiseRanges( 1 ), noiseRanges( end ) ], chanceLevel * [ 1, 1 ], '-.k', 'linewidth', lw )
% set( gca, 'xlim', [ 0, 0.45 ], 'ylim', [ 0, 1.1 ] )
% xlabel( 'Noise level' )
% title( 'Upper' )
% 
% 
% 
% chanceLevel = 1 / 8;
% 
% figure( 'position', [ 100, 100, 450, 250 ] )
% subplot( 1, 2, 1 )
% hold on
% for nCoding = 1 : 2
%     nClassifier = 1;
%     DA = accDir_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '-o', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 2;
%     DA = accDir_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--s', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 3;
%     DA = accDir_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--d', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 4;
%     DA = accDir_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--^', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 5;
%     DA = accDir_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--v', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 6;
%     DA = accDir_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), ':+', 'color', colors( nCoding, : ), 'linewidth', lw )
%     clear nClassifier DA
% end; clear nCoding
% plot( [ noiseRanges( 1 ), noiseRanges( end ) ], chanceLevel * [ 1, 1 ], '-.k', 'linewidth', lw )
% set( gca, 'xlim', [ 0, 0.45 ], 'ylim', [ 0, 1.1 ] )
% ylabel( 'Orientation decoding accuracy' )
% xlabel( 'Noise level' )
% title( 'Lower' )
% subplot( 1, 2, 2 )
% hold on
% for nCoding = 1 : 2
%     nClassifier = 1;
%     DA = accDir_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '-o', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 2;
%     DA = accDir_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--s', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 3;
%     DA = accDir_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--d', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 4;
%     DA = accDir_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--^', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 5;
%     DA = accDir_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--v', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 6;
%     DA = accDir_2_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), ':+', 'color', colors( nCoding, : ), 'linewidth', lw )
%     clear nClassifier DA
% end; clear nCoding
% plot( [ noiseRanges( 1 ), noiseRanges( end ) ], chanceLevel * [ 1, 1 ], '-.k', 'linewidth', lw )
% set( gca, 'xlim', [ 0, 0.45 ], 'ylim', [ 0, 1.1 ] )
% xlabel( 'Noise level' )
% title( 'Upper' )
% legend( 'Naive Bayes; STEC', 'LDA; STEC', 'SVM; STEC', 'DT; STEC', 'EC; STEC', 'NN; STEC', 'Naive Bayes; SEC', 'LDA; SEC', 'SVM; SEC', 'DT; SEC', 'EC; SEC', 'NN; SEC', 'location', 'southwest' )
% 

%% Response for Bar with Noise (TEC)
% % 
% % noiseRanges = 0.025 * 2 .^ [ 0 : 4 ];
% % N_iter = 300;
% % 
% % bar_img = {};
% % bar_width = 0.1;
% % ct_theta = 0;
% % for bar_theta = pi * [ 0 : 0.125 : 0.875 ]
% %     ct_theta = ct_theta + 1;
% %     bar_img{ ct_theta, 1 } = [];
% %     ct_shift = 0;
% %     for bar_shift = -2 : 0.1 : 2
% %         ct_shift = ct_shift + 1;
% % 
% %         img = zeros( 64, 64 );
% %         % img = 0.5 * ones( 64, 64 );
% %         [ X_grid, Y_grid ] = meshgrid( linspace( -2, 2, 64 ), linspace( -2, 2, 64 ) );
% %         XY_grid = [];
% %         XY_grid( :, :, 1 ) = X_grid;
% %         XY_grid( :, :, 2 ) = Y_grid;
% %         XY_grid = reshape( XY_grid, [ 64 * 64, 2 ] );
% %         XY_grid = [ cos( bar_theta ), -sin( bar_theta ); sin( bar_theta ), cos( bar_theta ) ] * transpose( XY_grid );
% %         XY_grid = transpose( XY_grid );
% %         XY_grid = reshape( XY_grid, [ 64, 64, 2 ] );
% %         img( XY_grid( :, :, 2 ) > -bar_width - bar_shift & XY_grid( :, :, 2 ) < bar_width - bar_shift ) = 1;
% %         clear X_grid Y_grid XY_grid
% % 
% %         bar_img{ ct_theta, 1 }( :, :, ct_shift ) = img;
% %         clear img
% % 
% %     end; clear bar_shift ct_shift
% % end; clear bar_theta ct_theta
% % clear bar_width
% % 
% % 
% % 
% % Z_1_moving = cell( size( bar_img, 1 ), length( noiseRanges ), 2 );
% % Z_2_moving = cell( size( bar_img, 1 ), length( noiseRanges ), 2 );
% % 
% % for fn = 1 : 2
% % 
% %     if fn == 1
% %         load( 'Results_lambda_5_5_Objects.mat' )
% %     elseif fn == 2
% %         load( 'Results_lambda_001_001_Objects.mat' )
% %     end
% % 
% %     iter = 1;
% %     W_f = results{ iter, 1 };
% %     b_f = results{ iter, 2 };
% % 
% % 
% %     for r = 1 : size( bar_img, 1 )
% % 
% %         rX = {};
% %         for h = 1 : size( io_f, 1 )
% %             rX{ h, 1 } = 0 * ones( 1, nZ( h ) );
% %         end; clear h
% %         for noiseLevel = 1 : length( noiseRanges )
% %             for iter = 1 : 2 * N_iter
% %                 t_bar_img = bar_img{ r, 1 };
% %                 t_bar_img = t_bar_img + noiseRanges( noiseLevel ) * randn( size( t_bar_img ) );
% %                 t_bar_img( t_bar_img > 1 ) = 1;
% %                 t_bar_img( t_bar_img < 0 ) = 0;
% %                 sX = transpose( reshape( t_bar_img, [ 64 * 64, size( t_bar_img, 3 ) ] ) );
% %                 sX = permute( sX, [ 3, 2, 1 ] );
% %                 [ Z, E ] = STE_pred_sgm( sX, io_f, W_f, b_f, 'prior', rX );
% %                 Z_1_moving{ r, noiseLevel, fn }( :, :, iter ) = single( Z{ 1, 1 }( 21 + [ -4 : 4 ], :, : ) );
% %                 Z_2_moving{ r, noiseLevel, fn }( :, :, iter ) = single( Z{ 2, 1 }( 21 + [ -4 : 4 ], :, : ) );
% %             end; clear iter
% %         end; clear noiseLevel
% %         clear rX t_bar_img sX Z E
% % 
% %         disp( [ num2str( r ), ' / ', num2str( size( bar_img, 1 ) ) ] )
% % 
% %     end; clear r
% % 
% %     clear results iter W_f b_f
% % 
% % end; clear fn
% % 
% % 
% % save( 'Final_Results_Response_Noisy_Bar_TEC_Object.mat', 'noiseRanges', 'N_iter', 'bar_img', 'Z_1_moving', 'Z_2_moving' )
% % 

%% Decoding accuracy (TEC)
% %
% % load( 'Final_Results_Response_Noisy_Bar_TEC_Object.mat' )
% % 
% % 
% % accLoc_1_trans = zeros( 9, length( noiseRanges ), 2, 6 );
% % accLoc_2_trans = zeros( 9, length( noiseRanges ), 2, 6 );
% % 
% % for fn = 1 : 2
% %     for noiseLevel = 1 : length( noiseRanges )
% %         for r = 5%[ 5 : -1 : 1, 8 : -1 : 6 ]
% % 
% % 
% %             data_tr = NaN( 9 * N_iter, 64 );
% %             data_te = NaN( 9 * N_iter, 64 );
% %             idx_tr = NaN( 9 * N_iter, 1 );
% %             idx_te = NaN( 9 * N_iter, 1 );
% %             for iter = 1 : N_iter
% %                 data_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_1_moving{ r, noiseLevel, fn }( :, :, iter );
% %                 data_te( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_1_moving{ r, noiseLevel, fn }( :, :, N_iter + iter );
% %                 idx_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %                 idx_te( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %             end; clear iter
% % 
% %             Mdl = fitcnb( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 1 ) = accLoc_1_trans( :, noiseLevel, fn, 1 ) + transpose( accH );
% % 
% %             idx_out = classify( data_te, data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 2 ) = accLoc_1_trans( :, noiseLevel, fn, 2 ) + transpose( accH );
% % 
% %             Mdl = fitcecoc( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 3 ) = accLoc_1_trans( :, noiseLevel, fn, 3 ) + transpose( accH );
% % 
% %             Mdl = fitctree( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 4 ) = accLoc_1_trans( :, noiseLevel, fn, 4 ) + transpose( accH );
% % 
% %             Mdl = fitcensemble( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr, 'Method', 'Bag' );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 5 ) = accLoc_1_trans( :, noiseLevel, fn, 5 ) + transpose( accH );
% % 
% %             layers = [ ...
% %                 featureInputLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 32 )
% %                 reluLayer
% %                 fullyConnectedLayer( 16 )
% %                 reluLayer
% %                 fullyConnectedLayer( length( unique( idx_tr ) ) )
% %                 softmaxLayer
% %                 classificationLayer ];
% %             options = trainingOptions( 'sgdm' );
% %             net = trainNetwork( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), categorical( idx_tr ), layers, options );
% %             idx_out = predict( net, data_te );
% %             [ ~, idx_out ] = max( idx_out, [], 2 );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_1_trans( :, noiseLevel, fn, 6 ) = accLoc_1_trans( :, noiseLevel, fn, 6 ) + transpose( accH );
% % 
% %             clear data_tr data_te idx_tr idx_te idx_out acc accH
% % 
% % 
% %             data_tr = NaN( 9 * N_iter, 64 );
% %             data_te = NaN( 9 * N_iter, 64 );
% %             idx_tr = NaN( 9 * N_iter, 1 );
% %             idx_te = NaN( 9 * N_iter, 1 );
% %             for iter = 1 : N_iter
% %                 data_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_2_moving{ r, noiseLevel, fn }( :, :, iter );
% %                 data_te( ( iter - 1 ) * 9 + [ 1 : 9 ], : ) = Z_2_moving{ r, noiseLevel, fn }( :, :, N_iter + iter );
% %                 idx_tr( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %                 idx_te( ( iter - 1 ) * 9 + [ 1 : 9 ], 1 ) = [ 1 : 9 ];
% %             end; clear iter
% % 
% %             Mdl = fitcnb( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 1 ) = accLoc_2_trans( :, noiseLevel, fn, 1 ) + transpose( accH );
% % 
% %             idx_out = classify( data_te, data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 2 ) = accLoc_2_trans( :, noiseLevel, fn, 2 ) + transpose( accH );
% % 
% %             Mdl = fitcecoc( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 3 ) = accLoc_2_trans( :, noiseLevel, fn, 3 ) + transpose( accH );
% % 
% %             Mdl = fitctree( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 4 ) = accLoc_2_trans( :, noiseLevel, fn, 4 ) + transpose( accH );
% % 
% %             Mdl = fitcensemble( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), idx_tr, 'Method', 'Bag' );
% %             idx_out = predict( Mdl, data_te );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 5 ) = accLoc_2_trans( :, noiseLevel, fn, 5 ) + transpose( accH );
% % 
% %             layers = [ ...
% %                 featureInputLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 64 )
% %                 reluLayer
% %                 fullyConnectedLayer( 32 )
% %                 reluLayer
% %                 fullyConnectedLayer( 16 )
% %                 reluLayer
% %                 fullyConnectedLayer( length( unique( idx_tr ) ) )
% %                 softmaxLayer
% %                 classificationLayer ];
% %             options = trainingOptions( 'sgdm' );
% %             net = trainNetwork( data_tr + ( 10 ^ (-8) * randn( size( data_tr ) ) ), categorical( idx_tr ), layers, options );
% %             idx_out = predict( net, data_te );
% %             [ ~, idx_out ] = max( idx_out, [], 2 );
% %             acc = abs( idx_out - idx_te );
% %             accH = histcounts( acc, [ -0.5 : 1 : 8.5 ] );
% %             accLoc_2_trans( :, noiseLevel, fn, 6 ) = accLoc_2_trans( :, noiseLevel, fn, 6 ) + transpose( accH );
% % 
% %             clear data_tr data_te idx_tr idx_te idx_out acc accH
% % 
% % 
% %         end; clear r
% %         disp( [ '(', num2str( fn ), ', ', num2str( noiseLevel ), ') / (2, ', num2str( length( noiseRanges ) ), ')' ] )
% %     end; clear noiseLevel
% % end; clear fn
% % 
% % 
% % save( 'Final_Results_Decoding_Accuracy_Bar_TEC_Object.mat', 'noiseRanges', 'accLoc_1_trans', 'accLoc_2_trans' )
% %
% %
% load( 'Final_Results_Decoding_Accuracy_Bar_TEC_Object.mat' )
% 
% 
% colors = [ 1, 0, 0.5; 0, 1, 0.5 ];
% lw = 1;
% 
% 
% chanceLevel = 1 / 9;
% 
% % figure( 'position', [ 100, 100, 450, 250 ] )
% figure( 'position', [ 100, 100, 200, 250 ] )
% % subplot( 1, 2, 1 )
% hold on
% for nCoding = 1 : 2
%     nClassifier = 1;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '-o', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 2;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--s', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 3;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--d', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 4;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--^', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 5;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), '--v', 'color', colors( nCoding, : ), 'linewidth', lw )
%     nClassifier = 6;
%     DA = accLoc_1_trans( :, :, nCoding, nClassifier );
%     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
%     plot( noiseRanges, DA( 1, : ), ':+', 'color', colors( nCoding, : ), 'linewidth', lw )
%     clear nClassifier DA
% end; clear nCoding
% plot( [ noiseRanges( 1 ), noiseRanges( end ) ], chanceLevel * [ 1, 1 ], '-.k', 'linewidth', lw )
% % set( gca, 'xlim', [ 0, 0.45 ], 'ylim', [ 0, 1.1 ] )
% set( gca, 'xlim', [ 0, 0.45 ], 'ylim', [ 0.8, 1.05 ] )
% % ylabel( 'Position decoding accuracy' )
% xlabel( 'Noise level' )
% title( 'Lower' )
% % subplot( 1, 2, 2 )
% % hold on
% % for nCoding = 1 : 2
% %     nClassifier = 1;
% %     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
% %     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
% %     plot( noiseRanges, DA( 1, : ), '-o', 'color', colors( nCoding, : ), 'linewidth', lw )
% %     nClassifier = 2;
% %     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
% %     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
% %     plot( noiseRanges, DA( 1, : ), '--s', 'color', colors( nCoding, : ), 'linewidth', lw )
% %     nClassifier = 3;
% %     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
% %     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
% %     plot( noiseRanges, DA( 1, : ), '--d', 'color', colors( nCoding, : ), 'linewidth', lw )
% %     nClassifier = 4;
% %     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
% %     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
% %     plot( noiseRanges, DA( 1, : ), '--^', 'color', colors( nCoding, : ), 'linewidth', lw )
% %     nClassifier = 5;
% %     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
% %     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
% %     plot( noiseRanges, DA( 1, : ), '--v', 'color', colors( nCoding, : ), 'linewidth', lw )
% %     nClassifier = 6;
% %     DA = accLoc_2_trans( :, :, nCoding, nClassifier );
% %     DA = bsxfun( @rdivide, DA, sum( DA, 1 ) );
% %     plot( noiseRanges, DA( 1, : ), ':+', 'color', colors( nCoding, : ), 'linewidth', lw )
% %     clear nClassifier DA
% % end; clear nCoding
% % plot( [ noiseRanges( 1 ), noiseRanges( end ) ], chanceLevel * [ 1, 1 ], '-.k', 'linewidth', lw )
% % set( gca, 'xlim', [ 0, 0.45 ], 'ylim', [ 0, 1.1 ] )
% % xlabel( 'Noise level' )
% % title( 'Upper' )
% legend( 'Naive Bayes; STEC', 'LDA; STEC', 'SVM; STEC', 'DT; STEC', 'EC; STEC', 'NN; STEC', 'Naive Bayes; TEC', 'LDA; TEC', 'SVM; TEC', 'DT; TEC', 'EC; TEC', 'NN; TEC', 'location', 'southwest' )
% 
