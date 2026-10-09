// ================================================
// 2D Radio Tomography Imaging
// Revised & Optimized Version
// ================================================

// Store script path BEFORE clear (survives re-run)
RTI_SCRIPT_PATH = get_absolute_file_path('RTI.sce') + 'RTI.sce';

clc
clear

// Restore after clear
RTI_SCRIPT_PATH = get_absolute_file_path('RTI.sce') + 'RTI.sce';

// ================================================
// Jet colormap (compatible with all Scilab versions)
// ================================================
function cmap = jetmap(n)
    t = linspace(0, 1, n)';
    r = max(0, min(1, 1.5 - abs(4*t - 3)));
    g = max(0, min(1, 1.5 - abs(4*t - 2)));
    b = max(0, min(1, 1.5 - abs(4*t - 1)));
    cmap = [r, g, b];
endfunction

// ================================================
// CONFIGURATION
// ================================================
grid_size  = 500;
center     = grid_size / 2 + 0.5;
radius     = 225;
debug_mode = %f;

// ================================================
// GUI folder selector
// ================================================
base_path = uigetdir(pwd(), 'Select folder containing CSV files');

if base_path == '' then
    messagebox('No folder selected. Script aborted.', 'Cancelled', 'error');
    abort
end

if part(base_path, length(base_path)) ~= '\' then
    base_path = base_path + '\';
end

messagebox('Folder selected:' + ascii(10) + base_path + ascii(10) + ascii(10) + 'Click OK to start reconstruction.', 'Radio Tomography Imaging', 'info');

// ================================================
// Load CSV files
// ================================================
filenames = ['e1_wood_te.csv', 'e2_wood_te.csv', 'e3_wood_te.csv', 'e4_wood_te.csv', ..
             'e5_wood_te.csv', 'e6_wood_te.csv', 'e7_wood_te.csv', 'e8_wood_te.csv'];

E = list();
for k = 1:8
    fpath = base_path + filenames(k);
    if ~isfile(fpath) then
        messagebox('File not found:' + ascii(10) + fpath, 'File Error', 'error');
        abort
    end
    raw  = csvRead(fpath);
    E(k) = flipdim(raw, 1);
end

// ================================================
// Debug check
// ================================================
if debug_mode then
    disp('=== DEBUG INFO ===');
    disp('Size of E(1):');      disp(size(E(1)));
    disp('Max of E(1):');       disp(max(max(E(1))));
    disp('Min of E(1):');       disp(min(min(E(1))));
    disp('E(1) top-left 5x5:'); disp(E(1)(1:5, 1:5));
    disp('==================');
end

// ================================================
// Circle mask (vectorized)
// ================================================
[X, Y] = meshgrid(1:grid_size, 1:grid_size);
R      = sqrt((X - center).^2 + (Y - center).^2);
mask   = (R <= radius);

for k = 1:8
    E(k) = E(k) .* mask;
end

// ================================================
// Projection calculation (optimized)
// ================================================
E_sum = zeros(grid_size, grid_size);
for k = 1:8
    E_sum = E_sum + E(k);
end

proj     = list();
proj_sum = zeros(grid_size, grid_size);
for k = 1:8
    proj(k)  = E(k) .* (E_sum - E(k));
    proj_sum = proj_sum + proj(k);
end

// ================================================
// Load data matrix (8x8)
// ================================================
data_file = base_path + 'data.csv';

if ~isfile(data_file) then
    messagebox('data.csv not found in:' + ascii(10) + base_path, 'File Error', 'error');
    abort
end

data = csvRead(data_file);

if size(data, 1) ~= 8 | size(data, 2) ~= 8 then
    messagebox('ERROR: data.csv must be 8x8. Found: ' + string(size(data,1)) + 'x' + string(size(data,2)), 'Data Error', 'error');
    abort
end

nan_count = sum(sum(isnan(data)));
if nan_count > 0 then
    disp('Warning: ' + string(nan_count) + ' NaN entries found in data matrix.');
end

// ================================================
// Tomographic reconstruction
// ================================================
tomogram = zeros(grid_size, grid_size);

for i = 1:8
    for j = i+1:8
        if ~isnan(data(i,j)) then
            tomogram = tomogram + E(i) .* E(j) .* data(i,j);
        end
    end
end

// ================================================
// Safe division
// ================================================
proj_sum_safe                     = proj_sum;
proj_sum_safe(proj_sum_safe == 0) = %nan;
result                            = tomogram ./ proj_sum_safe;
result(isnan(result))             = 0;
result                            = result .* mask;

// ================================================
// Normalize to [0, 1]
// ================================================
result = result - min(result(:));
r_max  = max(result(:));

if r_max ~= 0 then
    result = result / r_max;
else
    messagebox('Warning: result is all zeros. Check input files and data matrix.', 'Warning', 'warn');
end

// ================================================
// Display result statistics
// ================================================
disp('=== RESULT STATISTICS ===');
disp('Min value : ' + string(min(result(:))));
disp('Max value : ' + string(max(result(:))));
disp('Mean value: ' + string(mean(result(:))));
disp('=========================');

// ================================================
// Plot: 2D Radio Tomography Imaging
// ================================================
x = 1:grid_size;
y = 1:grid_size;

fig = figure();
fig.background = -2;

colormap(jetmap(256));
cmap      = gcf().color_map;
cmap(1,:) = [0, 0, 0.5];
gcf().color_map = cmap;

result(mask == 0) = -0.01;

Sgrayplot(x, y, result);

ax = gca();
ax.data_bounds       = [1, 1; 500, 500];
ax.tight_limits      = ["on", "on"];
ax.background        = color(0, 0, 128);
ax.filled            = "on";
ax.box               = "on";
ax.font_size         = 2;
ax.x_label.font_size = 2;
ax.y_label.font_size = 2;
ax.title.font_size   = 3;

colorbar();
xtitle('2D Radio Tomography Imaging', 'X Coordinate', 'Y Coordinate');

cb_axes            = gcf().children(1);
cb_axes.background = color(0, 0, 128);
cb_axes.filled     = "on";

cb_pos = cb_axes.axes_bounds;

xstring(cb_pos(1) + cb_pos(3) + 0.005, cb_pos(2), 'HIGH');
t_high            = gce();
t_high.font_size  = 2;
t_high.font_style = 1;
t_high.foreground = color('red');

xstring(cb_pos(1) + cb_pos(3) + 0.005, cb_pos(2) + cb_pos(4), 'LOW');
t_low            = gce();
t_low.font_size  = 2;
t_low.font_style = 1;
t_low.foreground = color('blue');

// ================================================
// Refresh callback function
// ================================================
function refresh_callback()
    // Pop up file picker for new data CSV
    new_data_file = uigetfile('*.csv', pwd(), 'Select new experiment data');

    if new_data_file == '' then
        messagebox('No file selected.', 'Cancelled', 'info');
        return
    end

    // Load and validate
    new_data = csvRead(new_data_file);

    if size(new_data, 1) ~= 8 | size(new_data, 2) ~= 8 then
        messagebox('ERROR: Selected file must be 8x8. Found: ' + string(size(new_data,1)) + 'x' + string(size(new_data,2)), 'Data Error', 'error');
        return
    end

    nan_count = sum(sum(isnan(new_data)));
    if nan_count > 0 then
        disp('Warning: ' + string(nan_count) + ' NaN entries found in new data matrix.');
    end

    // Recompute tomogram with new data
    new_tomogram = zeros(grid_size, grid_size);
    for i = 1:8
        for j = i+1:8
            if ~isnan(new_data(i,j)) then
                new_tomogram = new_tomogram + E(i) .* E(j) .* new_data(i,j);
            end
        end
    end

    // Safe division
    new_result                    = new_tomogram ./ proj_sum_safe;
    new_result(isnan(new_result)) = 0;
    new_result                    = new_result .* mask;

    // Normalize
    new_result = new_result - min(new_result(:));
    r_max      = max(new_result(:));
    if r_max ~= 0 then
        new_result = new_result / r_max;
    else
        messagebox('Warning: result is all zeros.', 'Warning', 'warn');
        return
    end

    // Display updated statistics
    disp('=== UPDATED RESULT STATISTICS ===');
    disp('File      : ' + new_data_file);
    disp('Min value : ' + string(min(new_result(:))));
    disp('Max value : ' + string(max(new_result(:))));
    disp('Mean value: ' + string(mean(new_result(:))));
    disp('=================================');

    // Push outside-circle below colormap range
    new_result(mask == 0) = -0.01;

    // Clear and redraw figure
    clf(fig);
    colormap(jetmap(256));
    cmap      = gcf().color_map;
    cmap(1,:) = [0, 0, 0.5];
    gcf().color_map = cmap;

    Sgrayplot(x, y, new_result);

    ax = gca();
    ax.data_bounds       = [1, 1; 500, 500];
    ax.tight_limits      = ["on", "on"];
    ax.background        = color(0, 0, 128);
    ax.filled            = "on";
    ax.box               = "on";
    ax.font_size         = 2;
    ax.x_label.font_size = 2;
    ax.y_label.font_size = 2;
    ax.title.font_size   = 3;

    colorbar();
    xtitle('2D Radio Tomography Imaging', 'X Coordinate', 'Y Coordinate');

    cb_axes            = gcf().children(1);
    cb_axes.background = color(0, 0, 128);
    cb_axes.filled     = "on";

    cb_pos = cb_axes.axes_bounds;

    xstring(cb_pos(1) + cb_pos(3) + 0.005, cb_pos(2), 'HIGH');
    t_high            = gce();
    t_high.font_size  = 2;
    t_high.font_style = 1;
    t_high.foreground = color('red');

    xstring(cb_pos(1) + cb_pos(3) + 0.005, cb_pos(2) + cb_pos(4), 'LOW');
    t_low            = gce();
    t_low.font_size  = 2;
    t_low.font_style = 1;
    t_low.foreground = color('blue');

    // Re-add Refresh button after clf()
    uicontrol(fig, ..
        'Style',           'pushbutton', ..
        'String',          '↻  Refresh', ..
        'FontSize',        12, ..
        'FontWeight',      'bold', ..
        'BackgroundColor', [0.2 0.5 0.8], ..
        'ForegroundColor', [1 1 1], ..
        'Units',           'normalized', ..
        'Position',        [0.01 0.01 0.12 0.06], ..
        'Callback',        'refresh_callback()');

endfunction

// ================================================
// Add Refresh Button to figure
// ================================================
uicontrol(fig, ..
    'Style',           'pushbutton', ..
    'String',          '↻  Refresh', ..
    'FontSize',        12, ..
    'FontWeight',      'bold', ..
    'BackgroundColor', [0.2 0.5 0.8], ..
    'ForegroundColor', [1 1 1], ..
    'Units',           'normalized', ..
    'Position',        [0.01 0.01 0.12 0.06], ..
    'Callback',        'refresh_callback()');
