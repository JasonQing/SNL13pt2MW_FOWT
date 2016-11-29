function ucr = up_crossing_rate(data,level,imeth)
% UP_CROSSING_RATE return the up crossing rate of signal S with duration t
% at given level.
narginchk(1, 3);

% check the level input
if nargin < 2
	% set standard value 0, if level is not given
    level = 0;
end

% check interpolation method input
if nargin < 3
    imeth = 'linear';
end

time = data(end,1) - data(1, 1); % first column of data is time

ucr = zeros(1, size(data, 2));
for i = 1 : size(data, 2)
    [ind,~,~] = crossing(data(:,i),data(:, 1),level(1,i),imeth);   
    ucr(1, i) = (size(ind, 2)) /time;
end

end

function [ind,t0,s0] = crossing(S,t,level,imeth)
% UP CROSSING find the up crossings of a given level of a signal
%   ind = CROSSING(S) returns an index vector ind, the signal
%   S crosses zero at ind or at between ind and ind+1
%   [ind,t0] = CROSSING(S,t) additionally returns a time
%   vector t0 of the zero crossings of the signal S. The crossing
%   times are linearly interpolated between the given times t
%   [ind,t0] = CROSSING(S,t,level) returns the crossings of the
%   given level instead of the zero crossings
%   ind = CROSSING(S,[],level) as above but without time interpolation
%   [ind,t0] = CROSSING(S,t,level,par) allows additional parameters
%   par = {'none'|'linear'}.
%	With interpolation turned off (par = 'none') this function always
%	returns the value left of the zero (the data point thats nearest
%   to the zero AND smaller than the zero crossing).
%
%	[ind,t0,s0] = ... also returns the data vector corresponding to 
%	the t0 values.
%
%	[ind,t0,s0,t0close,s0close] additionally returns the data points
%	closest to a zero crossing in the arrays t0close and s0close.
%
%	This version has been revised incorporating the good and valuable
%	bugfixes given by users on Matlabcentral. Special thanks to
%	Howard Fishman, Christian Rothleitner, Jonathan Kellogg, and
%	Zach Lewis for their input. 

% Steffen Brueckner, 2002-09-25
% Steffen Brueckner, 2007-08-27		revised version

% Copyright (c) Steffen Brueckner, 2002-2007
% brueckner@sbrs.net

% check the number of input arguments
% error(nargchk(1,4,nargin));
narginchk(1, 4);
% check the time vector input for consistency
if nargin < 2 || isempty(t)
	% if no time vector is given, use the index vector as time
    t = 1:length(S);
elseif length(t) ~= length(S)
	% if S and t are not of the same length, throw an error
    error('t and S must be of identical length!');    
end

% check the level input
if nargin < 3
	% set standard value 0, if level is not given
    level = 0;
end

% check interpolation method input
if nargin < 4
    imeth = 'linear';
end

% make row vectors
t = t(:)';
S = S(:)';

% always search for zeros. So if we want the crossing of 
% any other threshold value "level", we subtract it from
% the values and search for zeros.
S   = S - level;

% first look for exact zeros
ind0 = find( S == 0 ); 

S1 = S(1:end-1);S2 = S(2:end);
% then look for zero crossings between data points
SS = S1.* S2;
dS = S2 - S1;
ind1 = find( SS < 0 & dS >0 );

% bring exact zeros and "in-between" zeros together 
ind = sort([ind0 ind1]);

% and pick the associated time values
t0 = t(ind); 
s0 = S(ind);

if strcmp(imeth,'linear')
    % linear interpolation of crossing
    for ii=1:length(t0)
        if abs(S(ind(ii))) > eps(S(ind(ii)))
            % interpolate only when data point is not already zero
            NUM = (t(ind(ii)+1) - t(ind(ii)));
            DEN = (S(ind(ii)+1) - S(ind(ii)));
            DELTA =  NUM / DEN;
            t0(ii) = t0(ii) - S(ind(ii)) * DELTA;
            % I'm a bad person, so I simply set the value to zero
            % instead of calculating the perfect number ;)
            s0(ii) = 0;
        end
    end
end

% Addition:
% Some people like to get the data points closest to the zero crossing,
% so we return these as well
% [CC,II] = min(abs([S(ind-1) ; S(ind) ; S(ind+1)]),[],1); 
% ind2 = ind + (II-2); %update indices 
% 
% t0close = t(ind2);
% s0close = S(ind2);
end