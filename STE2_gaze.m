function [ sX, sX_learn ] = STE2_gaze( sX, info_X_sX, nPred )


nV = prod( info_X_sX( 2, : ), 2 );

miniBatchSize = size( sX, 1 );

% candidate position
cand_pos = info_X_sX( 1, : ) - info_X_sX( 2, : );
cand_pos_ind = prod( cand_pos, 2 );

% initial position
init_pos = NaN( miniBatchSize, 2 );
init_pos_ind = NaN( miniBatchSize, 1 );
for s = 1 : miniBatchSize
    init_pos_ind( s, 1 ) = randperm( cand_pos_ind, 1 );
end
[ init_pos( :, 1 ), init_pos( :, 2 ) ] = ind2sub( cand_pos, init_pos_ind );

ttsX = NaN( miniBatchSize, nV, prod( nPred, 2 ) );
for iter = 1 : nPred( 2 )
    
    if iter > 1
        init_pos = curr_pos;
    end
    
    % extra space
    ext_space = [ init_pos( :, 1 ) - 1, cand_pos( 1, 1 ) - init_pos( :, 1 ), init_pos( :, 2 ) - 1, cand_pos( 1, 2 ) - init_pos( :, 2 ) ];
    
    % available shift
    ava_shift = floor( ext_space / ( nPred( 1 ) - 1 ) );
    ava_shift( ava_shift < info_X_sX( 3, 1 ) ) = NaN;
    ava_shift( ava_shift > info_X_sX( 3, 2 ) ) = info_X_sX( 3, 2 );
    
    % moving priority (1st or 2nd Dim.)
    mov_prior = NaN( miniBatchSize, 1 );
    for s = 1 : miniBatchSize
        if all( isnan( ava_shift( s, 1 : 4 ) ) )
            mov_prior( s, 1 ) = 0;
        elseif ~all( isnan( ava_shift( s, 1 : 2 ) ) ) && all( isnan( ava_shift( s, 3 : 4 ) ) )
            mov_prior( s, 1 ) = 1;
        elseif all( isnan( ava_shift( s, 1 : 2 ) ) ) && ~all( isnan( ava_shift( s, 3 : 4 ) ) )
            mov_prior( s, 1 ) = 2;
        else
            mov_prior( s, 1 ) = randperm( 2, 1 );
        end
    end
    
    % vector of shift
    vec_shift = NaN( miniBatchSize, 2 );
    for s = 1 : miniBatchSize
        
        if mov_prior( s, 1 ) == 0
            
            vec_shift( s, 1 : 2 ) = 0;
            
        elseif mov_prior( s, 1 ) == 1
            
            if isnan( ava_shift( s, 1 ) )
                % positive (2) or negative (1) selection
                pn_select = 2;
            elseif isnan( ava_shift( s, 2 ) )
                pn_select = 1;
            else
                pn_select = randperm( 2, 1 );
            end
            % candidate shift
            cand_shift = [ info_X_sX( 3, 1 ) : ava_shift( s, pn_select ) ];
            % shift magnitude
            shift_mag = cand_shift( 1, randperm( length( cand_shift ), 1 ) );
            % determine shift vector
            vec_shift( s, 1 ) = ( ( -1 ) ^ pn_select ) * shift_mag;
            
            if all( isnan( ava_shift( s, 3 : 4 ) ) )
                pn_select = 0;
            elseif isnan( ava_shift( s, 3 ) )
                % positive (2) or negative (1) selection
                pn_select = 2;
            elseif isnan( ava_shift( s, 4 ) )
                pn_select = 1;
            else
                pn_select = randperm( 2, 1 );
            end
            if pn_select == 0
                % determine shift vector
                vec_shift( s, 2 ) = 0;
            else
                % candidate shift
                cand_shift = [ 0 : min( [ shift_mag, ava_shift( s, 2 + pn_select ) ], [], 2 ) ];
                % shift magnitude
                shift_mag = cand_shift( 1, randperm( length( cand_shift ), 1 ) );
                % determine shift vector
                vec_shift( s, 2 ) = ( ( -1 ) ^ pn_select ) * shift_mag;
            end
            
        elseif mov_prior( s, 1 ) == 2
            
            if isnan( ava_shift( s, 3 ) )
                % positive (2) or negative (1) selection
                pn_select = 2;
            elseif isnan( ava_shift( s, 4 ) )
                pn_select = 1;
            else
                pn_select = randperm( 2, 1 );
            end
            % candidate shift
            cand_shift = [ info_X_sX( 3, 1 ) : ava_shift( s, 2 + pn_select ) ];
            % shift magnitude
            shift_mag = cand_shift( 1, randperm( length( cand_shift ), 1 ) );
            % determine shift vector
            vec_shift( s, 2 ) = ( ( -1 ) ^ pn_select ) * shift_mag;
            
            if all( isnan( ava_shift( s, 1 : 2 ) ) )
                pn_select = 0;
            elseif isnan( ava_shift( s, 1 ) )
                % positive (2) or negative (1) selection
                pn_select = 2;
            elseif isnan( ava_shift( s, 2 ) )
                pn_select = 1;
            else
                pn_select = randperm( 2, 1 );
            end
            if pn_select == 0
                % determine shift vector
                vec_shift( s, 1 ) = 0;
            else
                % candidate shift
                cand_shift = [ 0 : min( [ shift_mag, ava_shift( s, pn_select ) ], [], 2 ) ];
                % shift magnitude
                shift_mag = cand_shift( 1, randperm( length( cand_shift ), 1 ) );
                % determine shift vector
                vec_shift( s, 1 ) = ( ( -1 ) ^ pn_select ) * shift_mag;
            end
            
        end
    end
    
    
    % ---------------------------------------------------------------------
    
    
    tsX = NaN( miniBatchSize, nV, nPred( 1 ) );
    
    curr_pos = init_pos;
    for ttt = 1 : nPred( 1 )
        
        for s = 1 : miniBatchSize
            img_full = reshape( sX( s, : ), [ info_X_sX( 1, 1 ), info_X_sX( 1, 2 ) ] );
            img_gaze = img_full( curr_pos( s, 1 ) - 1 + [ 1 : info_X_sX( 2, 1 ) ], curr_pos( s, 2 ) - 1 + [ 1 : info_X_sX( 2, 2 ) ] );
            tsX( s, :, ttt ) = reshape( img_gaze, [ 1, nV ] );
        end
        
        if ttt < nPred( 1 )
            curr_pos = curr_pos + vec_shift;
        end
        
    end
    
    ttsX( :, :, ( iter - 1 ) * nPred( 1 ) + [ 1 : nPred( 1 ) ] ) = tsX;
    
end


sX = ttsX;


% ---------------------------------------------------------------------


sX_learn = NaN( miniBatchSize * ( prod( nPred, 2 ) - 2 ), nV );

ct = 0;
for ttt = 2 : prod( nPred, 2 ) - 1
    sX_learn( ct + [ 1 : miniBatchSize ], : ) = sX( :, :, ttt );
    ct = ct + miniBatchSize;
end
