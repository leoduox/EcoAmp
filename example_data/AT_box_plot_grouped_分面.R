if (!requireNamespace("pacman", quietly = TRUE)) {
    install.packages("pacman", repos = "https://cloud.r-project.org")
}
pacman::p_load(optparse, openxlsx, agricolae, tidyverse, dplyr, tidyr, rstatix, grDevices, multcompView, RColorBrewer, ggpubr, ggbreak, ggh4x)

library(optparse) # 解析命令行参数
library(openxlsx)
###批量显著性检验及作图
library(agricolae)
library(tidyverse)
library(dplyr)
library(tidyr)
library(rstatix) # wilcox_test 检验使用  dunn_test

# 设置命令行选项
option_list = list(
    make_option(c("--input_file"), type = "character", default='D:/00_Software/03_Coding/python_Project/GUI_Leaning/QT6/07program/python_script/example_data/bar_plot_grouped_data.xlsx',help = "Input Excel file path"),
    make_option(c("--input_file_sheet_num"), type = "numeric", default = 1, help = "Sheet number of the input Excel file"),
    make_option(c("--input_group_file"), type = "character", default='D:/00_Software/03_Coding/python_Project/GUI_Leaning/QT6/07program/python_script/example_data/bar_plot_grouped_group.xlsx',help = "Input group Excel file path"),
    make_option(c("--input_group_file_sheet_num"), type = "numeric", default = 1, help = "Sheet number of the input group Excel file"),
    make_option(c("--output_file"), type = "character", help = "Output PDF file path"),
    
    make_option(c("--picture_width"), type = "numeric", default = 8, help = "Width of the picture"),
    make_option(c("--picture_height"), type = "numeric", default = 6, help = "Height of the picture"),
    make_option(c("--font_Style"), type = "character", default = "Arial", help = "Font style for text"),
    
    make_option(c("--axis_text_x_Alignment"), type = "character", default = "middle", help = "Alignment for x-axis text: middle, left, right"),
    make_option(c("--axis_text_y_Alignment"), type = "character", default = "middle", help = "Alignment for y-axis text: middle, left, right"),
    
    make_option(c("--axis_text_x_angle"), type = "numeric", default = 0, help = "Angle for x-axis text"),
    make_option(c("--axis_text_y_angle"), type = "numeric", default = 0, help = "Angle for y-axis text"),
    
    make_option(c("--show_x_title"), type = "logical", default = TRUE, help = "Whether to show x-axis title"),
    make_option(c("--x_title_text"), type = "character", default = "", help = "Text for x-axis title"),
    make_option(c("--show_y_title"), type = "logical", default = TRUE, help = "Whether to show y-axis title"),
    make_option(c("--y_title_text"), type = "character", default = "", help = "Text for y-axis title"),
    
    make_option(c("--Size_x_title"), type = "numeric", default = 14, help = "Size of x-axis title"),
    make_option(c("--x_title_font_weight"), type = "character", default = "plain", help = "Font weight for x-axis title: bold, plain, italic, bold.italic"),
    make_option(c("--x_title_color"), type = "character", default = "black", help = "Color of x-axis title"),
    
    make_option(c("--Size_y_title"), type = "numeric", default = 14, help = "Size of y-axis title"),
    make_option(c("--y_title_font_weight"), type = "character", default = "plain", help = "Font weight for y-axis title: bold, plain, italic, bold.italic"),
    make_option(c("--y_title_color"), type = "character", default = "black", help = "Color of y-axis title"),
    
    make_option(c("--Size_x_Axis"), type = "numeric", default = 14, help = "Size of x-axis labels"),
    make_option(c("--x_Axis_font_weight"), type = "character", default = "plain", help = "Font weight for x-axis labels: bold, plain, italic, bold.italic"),
    make_option(c("--x_Axis_color"), type = "character", default = "black", help = "Color of x-axis labels"),
    
    make_option(c("--Size_y_Axis"), type = "numeric", default = 14, help = "Size of y-axis labels"),
    make_option(c("--y_Axis_font_weight"), type = "character", default = "plain", help = "Font weight for y-axis labels: bold, plain, italic, bold.italic"),
    make_option(c("--y_Axis_color"), type = "character", default = "black", help = "Color of y-axis labels"),
    
    make_option(c("--show_title"), type = "logical", default = FALSE, help = "Whether to show the title"),
    make_option(c("--title_name"), type = "character", default = "Title2228", help = "Text for the plot title"),
    make_option(c("--title_size"), type = "numeric", default = 20, help = "Size of the title"),
    make_option(c("--title_color"), type = "character", default = "black", help = "Color of the title"),
    make_option(c("--title_font_weight"), type = "character", default = "plain", help = "Font weight for the title: bold, plain, italic, bold.italic"),
    
    make_option(c("--show_legend"), type = "logical", default = TRUE, help = "Whether to show the legend"),
    make_option(c("--legend_text_font_weight"), type = "character", default = "plain", help = "Font weight for legend text: bold, plain, italic, bold.italic"),
    make_option(c("--legend_text_color"), type = "character", default = "black", help = "Color of legend text"),
    make_option(c("--legend_text_font_size"), type = "numeric", default = 14, help = "Font size for legend text"),
    
    make_option(c("--legend_title_font_size"), type = "numeric", default = 14, help = "Font size for legend title"),
    make_option(c("--legend_title_font_weight"), type = "character", default = "plain", help = "Font weight for legend title: bold, plain, italic, bold.italic"),
    make_option(c("--legend_title_color"), type = "character", default = "black", help = "Color of legend title"),
    
    make_option(c("--custom_legend_title_name"), type = "character", default = "group", help = "Custom legend title name"),
    make_option(c("--legend_position"), type = "character", default = "right", help = "Position of the legend: right, left, top, bottom, inside"),
    make_option(c("--legend_direction"), type = "character", default = "vertical", help = "Direction of the legend: vertical, horizontal"),
    make_option(c("--inside_legend_x"), type = "numeric", default = 0.5, help = "X position for inside legend"),
    make_option(c("--inside_legend_y"), type = "numeric", default = 0.8, help = "Y position for inside legend"),
    
    make_option(c("--show_x_刻度"), type = "logical", default = TRUE, help = "Whether to show x-axis ticks"),
    make_option(c("--show_y_刻度"), type = "logical", default = TRUE, help = "Whether to show y-axis ticks"),
    make_option(c("--x_刻度长度"), type = "numeric", default = 0.4, help = "Length of x-axis ticks"),
    make_option(c("--y_刻度长度"), type = "numeric", default = 0.4, help = "Length of y-axis ticks"),
    make_option(c("--x_刻度颜色"), type = "character", default = "black", help = "Color of x-axis ticks"),
    make_option(c("--y_刻度颜色"), type = "character", default = "black", help = "Color of y-axis ticks"),
    make_option(c("--x_刻度粗细"), type = "numeric", default = 0.8, help = "Thickness of x-axis ticks"),
    make_option(c("--y_刻度粗细"), type = "numeric", default = 0.8, help = "Thickness of y-axis ticks"),
    make_option(c("--x刻度位置"), type = "character", default = "outside", help = "Position of x-axis ticks: inside, outside"),
    make_option(c("--y刻度位置"), type = "character", default = "outside", help = "Position of y-axis ticks: inside, outside"),
    
    make_option(c("--show_x_Axis_border"), type = "logical", default = TRUE, help = "Whether to show x-axis border"),
    make_option(c("--show_y_Axis_border"), type = "logical", default = TRUE, help = "Whether to show y-axis border"),
    make_option(c("--colour_x_Axis_border"), type = "character", default = "black", help = "Color of x-axis border"),
    make_option(c("--colour_y_Axis_border"), type = "character", default = "black", help = "Color of y-axis border"),
    make_option(c("--size_x_Axis_border"), type = "numeric", default = 0.8, help = "Size of x-axis border"),
    make_option(c("--size_y_Axis_border"), type = "numeric", default = 0.8, help = "Size of y-axis border"),
    
    make_option(c("--show_panel_border"), type = "logical", default = FALSE, help = "Whether to show panel border"),
    make_option(c("--panel_border_colour"), type = "character", default = "black", help = "Color of panel border"),
    make_option(c("--panel_border_size"), type = "numeric", default = 1, help = "Size of panel border"),
    
    make_option(c("--bar_width"), type = "numeric", default = 0.8, help = "Width of the bars"),
    make_option(c("--bar_inner_width"), type = "numeric", default = 0, help = "Inner width of the bars"),
    make_option(c("--bar_alpha"), type = "numeric", default = 1, help = "Transparency of the bars"),
    
    make_option(c("--bar_border_size"), type = "numeric", default = 0.5, help = "Size of the bar border"),
    make_option(c("--bar_border_color"), type = "character", default = "black", help = "Color of the bar border"),
    make_option(c("--bar_border_color_follow_bar"), type = "logical", default = FALSE, help = "Whether the bar border color follows the bar color"),
    
    make_option(c("--bar_color_set"), type = "character", default = "Set1", help = "Color palette for the bars"),
    make_option(c("--bar_color_show_custom_color"), type = "logical", default = FALSE, help = "Whether to use custom colors for bars"),
    make_option(c("--custom_colors1"), type = "character", default = "grey", help = "Custom color for the first bar"),
    make_option(c("--custom_colors2"), type = "character", default = "grey", help = "Custom color for the second bar"),
    make_option(c("--custom_colors3"), type = "character", default = "grey", help = "Custom color for the third bar"),
    make_option(c("--custom_colors4"), type = "character", default = "grey", help = "Custom color for the fourth bar"),
    make_option(c("--custom_colors5"), type = "character", default = "grey", help = "Custom color for the fifth bar"),
    make_option(c("--custom_colors6"), type = "character", default = "grey", help = "Custom color for the sixth bar"),
    make_option(c("--custom_colors7"), type = "character", default = "grey", help = "Custom color for the seventh bar"),
    make_option(c("--custom_colors8"), type = "character", default = "grey", help = "Custom color for the eighth bar"),
    make_option(c("--custom_colors9"), type = "character", default = "grey", help = "Custom color for the ninth bar"),
    make_option(c("--custom_colors10"), type = "character", default = "grey", help = "Custom color for the tenth bar"),
    
    make_option(c("--show_point"), type = "logical", default = FALSE, help = "Whether to show points on the plot"),
    make_option(c("--point_jitter_width"), type = "numeric", default = 0.3, help = "Width of jitter for points"),
    make_option(c("--point_alpha"), type = "numeric", default = 0.5, help = "Transparency of the points"),
    make_option(c("--point_size"), type = "numeric", default = 2, help = "Size of the points"),
    make_option(c("--point_shape"), type = "numeric", default = 16, help = "Shape of the points"),
    make_option(c("--point_color"), type = "character", default = "black", help = "Color of the points"),
    make_option(c("--point_stroke"), type = "numeric", default = 1, help = "Stroke width of the points"),
    make_option(c("--point_color_follow_bar"), type = "logical", default = FALSE, help = "Whether the point color follows the bar color"),
    
    make_option(c("--show_errorbar"), type = "logical", default = TRUE, help = "Whether to show error bars"),
    make_option(c("--error_bar_color_follow_bar"), type = "logical", default = FALSE, help = "Whether the error bar color follows the bar color"),
    make_option(c("--errorbar_width"), type = "numeric", default = 0.3, help = "Width of the error bar"),
    make_option(c("--errorbar_size"), type = "numeric", default = 0.5, help = "Size of the error bar"),
    make_option(c("--error_bar_color"), type = "character", default = "black", help = "Color of the error bars"),
    
    make_option(c("--show_sig_letter"), type = "logical", default = TRUE, help = "Whether to show significance letters"),
    make_option(c("--sig_letter_type"), type = "character", default = "all", help = "Type of significance letters: 'group' or 'all'"),
    make_option(c("--sig_letter_level"), type = "numeric", default = 0.05, help = "Significance level for letters"),
    make_option(c("--sig_letter_method"), type = "character", default = "LSD", help = "Method for significance letters: 'LSD', 'Duncan', or 'TukeyHSD'"),
    make_option(c("--letter_color"), type = "character", default = "black", help = "Color of the significance letters"),
    make_option(c("--letter_size"), type = "numeric", default = 6, help = "Size of the significance letters"),
    make_option(c("--letter_style"), type = "character", default = "plain", help = "Style of the significance letters: 'bold', 'plain', 'italic', or 'bold.italic'"),
    make_option(c("--letter_height_factor"), type = "numeric", default = 0.05, help = "Factor to adjust the height of the significance letters"),
    make_option(c("--letter_color_follow_bar"), type = "logical", default = FALSE, help = "Whether the letter color follows the bar color"),
    
    make_option(c("--show_sig_star"), type = "logical", default = FALSE, help = "Whether to show significance stars"),
    make_option(c("--sig_star_method"), type = "character", default = "t_test", help = "Method for significance stars: 't_test', 'wilcox_test', or 'kruskal_test'"),
    make_option(c("--sig_padj_method"), type = "character", default = "holm", help = "Method for p-value adjustment: 'holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'fdr', or 'none'"),
    make_option(c("--hide_ns"), type = "logical", default = FALSE, help = "Whether to hide non-significant results"),
    make_option(c("--star_or_pvalue"), type = "character", default = "p.adj.signif", help = "Type of significance to show: 'p', 'p.adj', 'p.signif', or 'p.adj.signif'"),
    make_option(c("--sig_star_size"), type = "numeric", default = 6, help = "Size of the significance stars"),
    make_option(c("--star_font_weight"), type = "character", default = "plain", help = "Font weight of the significance stars: 'bold', 'plain', 'italic', or 'bold.italic'"),
    make_option(c("--star_line_type"), type = "numeric", default = 1, help = "Line type for the significance stars"),
    make_option(c("--star_line_tiplength"), type = "numeric", default = 0.03, help = "Tip length of the significance star lines"),
    make_option(c("--sig_star_color"), type = "character", default = "black", help = "Color of the significance stars"),
    
    make_option(c("--show_plot_background"), type = "logical", default = FALSE, help = "Whether to show plot background"),
    make_option(c("--show_panel_background"), type = "logical", default = FALSE, help = "Whether to show panel background"),
    make_option(c("--plot_background_color"), type = "character", default = "#339ACE", help = "Color of plot background"),
    make_option(c("--panel_background_color"), type = "character", default = "#EBEBEB", help = "Color of panel background"),
    
    make_option(c("--show_x_grid_line"), type = "logical", default = FALSE, help = "Whether to show x-axis grid lines"),
    make_option(c("--show_y_grid_line"), type = "logical", default = FALSE, help = "Whether to show y-axis grid lines"),
    
    make_option(c("--x_grid_line_color"), type = "character", default = "#FFFFFF", help = "Color of x-axis grid lines"),
    make_option(c("--x_grid_line_size"), type = "numeric", default = 1, help = "Size of x-axis grid lines"),
    
    make_option(c("--y_grid_line_color"), type = "character", default = "#FFFFFF", help = "Color of y-axis grid lines"),
    make_option(c("--y_grid_line_size"), type = "numeric", default = 1, help = "Size of y-axis grid lines"),
    
    make_option(c("--from_top_distance"), type = "numeric", default = 0.3, help = "Top distance for the plot"),
    make_option(c("--from_bottom_distance"), type = "numeric", default = 0, help = "Bottom distance for the plot"),
    make_option(c("--ylim_min"), type = "numeric", default = NA, help = "Minimum limit for y-axis"),
    make_option(c("--ylim_max"), type = "numeric", default = NA, help = "Maximum limit for y-axis"),
    
    make_option(c("--是否自定义y刻度"), type = "logical", default = FALSE, help = "Whether to customize y-axis ticks"),
    make_option(c("--y刻度"), type = "character", default = "0,1,5,8,15", help = "Custom y-axis ticks"),
    
    make_option(c("--format_y_number_style"), type = "character", default = "", help = "Number format style for y-axis: %0.2f, %.2e"),
    
    make_option(c("--是否设置y轴断点"), type = "logical", default = FALSE, help = "Whether to set y-axis break"),
    make_option(c("--y轴断点下限"), type = "numeric", default = 10, help = "Lower limit of y-axis break"),
    make_option(c("--y轴断点上限"), type = "numeric", default = 40, help = "Upper limit of y-axis break"),
    make_option(c("--断区的宽度"), type = "numeric", default = 0.1, help = "Width of the y-axis break"),
    
    make_option(c("--code_text"), type = "character", default = "", help = "Code text for the plot"),
    
    make_option(c("--show_average_point"), type = "logical", default = FALSE, help = "Whether to show the average point on the plot"),
    make_option(c("--average_point_shape"), type = "numeric", default = 16, help = "Shape of the average point"),
    make_option(c("--average_point_size"), type = "numeric", default = 3, help = "Size of the average point"),
    make_option(c("--average_point_color"), type = "character", default = "grey", help = "Color of the average point"),
    make_option(c("--average_point_stroke"), type = "numeric", default = 1, help = "Stroke width of the average point"),
    
    make_option(c("--ncol"), type = "numeric", default = 3, help = "Number of columns for facet wrap"),
    make_option(c("--strip_position"), type = "character", default = "top", help = "Position of the facet strip. Options: 'top', 'bottom', 'left', 'right'"),
    make_option(c("--scales_method_y"), type = "character", default = "free", help = "Scaling method for axes. Options: 'fixed', 'free', 'free_x', 'free_y'"),
    make_option(c("--scales_method_x"), type = "character", default = "free", help = "Scaling method for axes. Options: 'fixed', 'free', 'free_x', 'free_y'"),
    make_option(c("--strip_background_color"), type = "character", default = "lightgrey", help = "Background color of the facet strip"),
    make_option(c("--strip_background_border_color"), type = "character", default = "black", help = "Border color of the facet strip background"),
    make_option(c("--strip_background_border_size"), type = "numeric", default = 1, help = "Border size of the facet strip background"),
    make_option(c("--strip_text_color"), type = "character", default = "black", help = "Color of the facet strip text"),
    make_option(c("--strip_text_size"), type = "numeric", default = 10, help = "Size of the facet strip text"),
    make_option(c("--strip_text_font_weight"), type = "character", default = "bold", help = "Font weight of the facet strip text"),
    make_option(c("--show_strip_text"), type = "logical", default = TRUE, help = "Whether to show the facet strip text"),
    make_option(c("--show_strip_background"), type = "logical", default = TRUE, help = "Whether to show the facet strip background"),
    
    make_option(c("--point_offset"), type = "numeric", default = 0.2, help = "Offset for the points"),
    make_option(c("--show_outlier_point"), type = "logical", default = FALSE, help = "Whether to show outlier points"),
    make_option(c("--outlier_shape"), type = "numeric", default = 16, help = "Shape of the outlier points"),
    make_option(c("--outlier_size"), type = "numeric", default = 3, help = "Size of the outlier points"),
    make_option(c("--outlier_color"), type = "character", default = "black", help = "Color of the outlier points"),
    make_option(c("--comparisons_method"), type = "character", default = "all_to_all", help = "Method for comparisons: t_test, wilcox_test, kruskal_test"),
    make_option(c("--sig_letter_padj"), type = "character", default = "all_to_all", help = "Method for comparisons: t_test, wilcox_test, kruskal_test"),
    
    make_option(c("--show_letter_duiqi"), type = "logical", default = FALSE, help = "Whether to show letter duplication"),
    make_option(c("--sig_star_offset"), type = "numeric", default = 0.1, help = "Offset for the significance stars"),
    make_option(c("--sig_star_interval"), type = "numeric", default = 0.1, help = "Interval for the significance stars"),
    
    make_option(c("--color_method"), type = "character", default = 'Group', help = "Color method (e.g., 'Group')"),
    make_option(c("--show_gradient_color"), type = "logical", default = TRUE, help = "Whether to show gradient color"),
    make_option(c("--gradient_color_name"), type = "character", default = 'gradient16', help = "Name of the gradient color"),
    make_option(c("--custom_colors11"), type = "character", default = 'grey', help = "Custom color 11"),
    make_option(c("--custom_colors12"), type = "character", default = 'grey', help = "Custom color 12"),
    make_option(c("--custom_colors13"), type = "character", default = 'grey', help = "Custom color 13"),
    make_option(c("--custom_colors14"), type = "character", default = 'grey', help = "Custom color 14"),
    make_option(c("--custom_colors15"), type = "character", default = 'grey', help = "Custom color 15"),
    make_option(c("--custom_colors16"), type = "character", default = 'grey', help = "Custom color 16"),
    make_option(c("--custom_colors17"), type = "character", default = 'grey', help = "Custom color 17"),
    make_option(c("--custom_colors18"), type = "character", default = 'grey', help = "Custom color 18"),
    make_option(c("--custom_colors19"), type = "character", default = 'grey', help = "Custom color 19"),
    make_option(c("--custom_colors20"), type = "character", default = 'grey', help = "Custom color 20")
)

# 解析命令行选项
parser = OptionParser(option_list = option_list)
args = parse_args(parser)

input_file = args$input_file
input_file_sheet_num = args$input_file_sheet_num
input_group_file = args$input_group_file
input_group_file_sheet_num = args$input_group_file_sheet_num
output_file = args$output_file

picture_width = args$picture_width
picture_height = args$picture_height
font_Style = args$font_Style

axis_text_x_Alignment = args$axis_text_x_Alignment
axis_text_y_Alignment = args$axis_text_y_Alignment

axis_text_x_angle = args$axis_text_x_angle
axis_text_y_angle = args$axis_text_y_angle

show_x_title = args$show_x_title
x_title_text = args$x_title_text
show_y_title = args$show_y_title
y_title_text = args$y_title_text

Size_x_title = args$Size_x_title
x_title_font_weight = args$x_title_font_weight
x_title_color = args$x_title_color

Size_y_title = args$Size_y_title
y_title_font_weight = args$y_title_font_weight
y_title_color = args$y_title_color

Size_x_Axis = args$Size_x_Axis
x_Axis_font_weight = args$x_Axis_font_weight
x_Axis_color = args$x_Axis_color

Size_y_Axis = args$Size_y_Axis
y_Axis_font_weight = args$y_Axis_font_weight
y_Axis_color = args$y_Axis_color

show_title = args$show_title
title_name = args$title_name
title_size = args$title_size
title_color = args$title_color
title_font_weight = args$title_font_weight

show_legend = args$show_legend
legend_text_font_weight = args$legend_text_font_weight
legend_text_color = args$legend_text_color
legend_text_font_size = args$legend_text_font_size

legend_title_font_size = args$legend_title_font_size
legend_title_font_weight = args$legend_title_font_weight
legend_title_color = args$legend_title_color

custom_legend_title_name = args$custom_legend_title_name
legend_position = args$legend_position
legend_direction = args$legend_direction
inside_legend_x = args$inside_legend_x
inside_legend_y = args$inside_legend_y

show_x_刻度 = args$show_x_刻度
show_y_刻度 = args$show_y_刻度
x_刻度长度 = args$x_刻度长度
y_刻度长度 = args$y_刻度长度
x_刻度颜色 = args$x_刻度颜色
y_刻度颜色 = args$y_刻度颜色
x_刻度粗细 = args$x_刻度粗细
y_刻度粗细 = args$y_刻度粗细
x刻度位置 = args$x刻度位置
y刻度位置 = args$y刻度位置

show_x_Axis_border = args$show_x_Axis_border
show_y_Axis_border = args$show_y_Axis_border
colour_x_Axis_border = args$colour_x_Axis_border
colour_y_Axis_border = args$colour_y_Axis_border
size_x_Axis_border = args$size_x_Axis_border
size_y_Axis_border = args$size_y_Axis_border
show_panel_border = args$show_panel_border
panel_border_colour = args$panel_border_colour
panel_border_size = args$panel_border_size

bar_width = args$bar_width
bar_inner_width = args$bar_inner_width
bar_alpha = args$bar_alpha
bar_border_size = args$bar_border_size
bar_border_color = args$bar_border_color
bar_border_color_follow_bar = args$bar_border_color_follow_bar

bar_color_set = args$bar_color_set
bar_color_show_custom_color = args$bar_color_show_custom_color
custom_colors1 = args$custom_colors1
custom_colors2 = args$custom_colors2
custom_colors3 = args$custom_colors3
custom_colors4 = args$custom_colors4
custom_colors5 = args$custom_colors5
custom_colors6 = args$custom_colors6
custom_colors7 = args$custom_colors7
custom_colors8 = args$custom_colors8
custom_colors9 = args$custom_colors9
custom_colors10 = args$custom_colors10

show_point = args$show_point
point_jitter_width = args$point_jitter_width
point_alpha = args$point_alpha
point_size = args$point_size
point_shape = args$point_shape
point_color = args$point_color
point_stroke = args$point_stroke
point_color_follow_bar = args$point_color_follow_bar

show_errorbar = args$show_errorbar
error_bar_color_follow_bar = args$error_bar_color_follow_bar
errorbar_width = args$errorbar_width
errorbar_size = args$errorbar_size
error_bar_color = args$error_bar_color

show_sig_letter = args$show_sig_letter
sig_letter_type = args$sig_letter_type
sig_letter_level = args$sig_letter_level
sig_letter_method = args$sig_letter_method
letter_color = args$letter_color
letter_size = args$letter_size
letter_style = args$letter_style
letter_height_factor = args$letter_height_factor
letter_color_follow_bar = args$letter_color_follow_bar

show_sig_star = args$show_sig_star
sig_star_method = args$sig_star_method
sig_padj_method = args$sig_padj_method
hide_ns = args$hide_ns
star_or_pvalue = args$star_or_pvalue
sig_star_size = args$sig_star_size
star_font_weight = args$star_font_weight
star_line_type = args$star_line_type
star_line_tiplength = args$star_line_tiplength
sig_star_color = args$sig_star_color

show_plot_background = args$show_plot_background
show_panel_background = args$show_panel_background
plot_background_color = args$plot_background_color
panel_background_color = args$panel_background_color

show_x_grid_line = args$show_x_grid_line
show_y_grid_line = args$show_y_grid_line

x_grid_line_color = args$x_grid_line_color
x_grid_line_size = args$x_grid_line_size

y_grid_line_color = args$y_grid_line_color
y_grid_line_size = args$y_grid_line_size

from_top_distance = args$from_top_distance
from_bottom_distance = args$from_bottom_distance
ylim_min = args$ylim_min
ylim_max = args$ylim_max

是否自定义y刻度 = args$是否自定义y刻度
y刻度 = args$y刻度

format_y_number_style = args$format_y_number_style

是否设置y轴断点 = args$是否设置y轴断点
y轴断点下限 = args$y轴断点下限
y轴断点上限 = args$y轴断点上限
断区的宽度 = args$断区的宽度

code_text = args$code_text

# 获取参数值
show_average_point = args$show_average_point  # 是否显示平均点
average_point_shape = args$average_point_shape  # 平均点的形状
average_point_size = args$average_point_size  # 平均点的大小
average_point_color = args$average_point_color  # 平均点的颜色
average_point_stroke = args$average_point_stroke  # 平均点的描边宽度

ncol = args$ncol
strip_position = args$strip_position
scales_method_y = args$scales_method_y
scales_method_x = args$scales_method_x
strip_background_color = args$strip_background_color
strip_background_border_color = args$strip_background_border_color
strip_background_border_size = args$strip_background_border_size
strip_text_color = args$strip_text_color
strip_text_size = args$strip_text_size
strip_text_font_weight = args$strip_text_font_weight
show_strip_text = args$show_strip_text
show_strip_background = args$show_strip_background

point_offset <- args$point_offset
show_outlier_point = args$show_outlier_point
outlier_shape = args$outlier_shape  # 不显示离群值
outlier_size = args$outlier_size
outlier_color = args$outlier_color
comparisons_method = args$comparisons_method
show_letter_duiqi = args$show_letter_duiqi
sig_star_offset = args$sig_star_offset
sig_star_interval = args$sig_star_interval

sig_letter_padj = args$sig_letter_padj


color_method = args$color_method
show_gradient_color = args$show_gradient_color
gradient_color_name = args$gradient_color_name
custom_colors11 = args$custom_colors11
custom_colors12 = args$custom_colors12
custom_colors13 = args$custom_colors13
custom_colors14 = args$custom_colors14
custom_colors15 = args$custom_colors15
custom_colors16 = args$custom_colors16
custom_colors17 = args$custom_colors17
custom_colors18 = args$custom_colors18
custom_colors19 = args$custom_colors19
custom_colors20 = args$custom_colors20

# 是否调试在Rstuiod----
是否调试在Rstuiod = F

if (是否调试在Rstuiod) {
    
    # 01传入参数设置----
    input_file = 'D:/00_Software/03_Coding/python_Project/GUI_Leaning/QT6/07program/python_script/example_data/bar_plot_grouped_data.xlsx'
    # input_file = 'C:/Users/law/Desktop/nc箱线图复现.xlsx'
    input_file_sheet_num = 1
    input_group_file = 'D:/00_Software/03_Coding/python_Project/GUI_Leaning/QT6/07program/python_script/example_data/bar_plot_grouped_group.xlsx'
    # input_group_file = 'C:/Users/law/Desktop/nc箱线图复现.xlsx'
    input_group_file_sheet_num = 1
    output_file = 'C:/Users/law/Desktop/1234.pdf'
    
    picture_width = 8
    picture_height = 6
    font_Style = "Arial"
    
    axis_text_x_Alignment = "middle" # x轴文本对齐方式 middle left right
    axis_text_y_Alignment = "middle" # x轴文本对齐方式 middle left right
    
    axis_text_x_angle = 0
    axis_text_y_angle = 0
    
    show_x_title = TRUE
    x_title_text = ''
    show_y_title = TRUE
    y_title_text = ''
    
    Size_x_title = 14
    x_title_font_weight = "plain" # 可选的有"bold", "plain", "italic" and "bold.italic"
    x_title_color = "black"
    
    Size_y_title = 14
    y_title_font_weight = "plain" # 可选的有"bold", "plain", "italic" and "bold.italic"
    y_title_color = "black"
    
    Size_x_Axis = 14
    x_Axis_font_weight = "plain" # 可选的有"bold", "plain", "italic" and "bold.italic"
    x_Axis_color = "black"
    
    Size_y_Axis = 14
    y_Axis_font_weight = "plain" # 可选的有"bold", "plain", "italic" and "bold.italic"
    y_Axis_color = "black"
    
    show_title = F
    title_name = "Title2228"
    title_size = 20
    title_color = "black"
    title_font_weight = "plain"  # 可选的有"bold", "plain", "italic" and "bold.italic"
    
    show_legend = F
    legend_text_font_weight = "plain" # 可选的有"bold", "plain", "italic" and "bold.italic"
    legend_text_color = "black"
    legend_text_font_size = 14
    
    legend_title_font_size = 14
    legend_title_font_weight = "plain" # 可选的有"bold", "plain", "italic" and "bold.italic"
    legend_title_color = "black"
    
    custom_legend_title_name = "group"
    legend_position = "right"  # "right", "left", "top", "bottom", "inside"
    legend_direction = "vertical"  # "vertical", "horizontal"
    inside_legend_x = 0.5
    inside_legend_y = 0.8
    
    
    show_x_刻度 = T
    show_y_刻度 = T
    x_刻度长度 = 0.4
    y_刻度长度 = 0.4
    x_刻度颜色 = "black"
    y_刻度颜色 = "black"
    x_刻度粗细 = 0.8
    y_刻度粗细 = 0.8
    x刻度位置 = "outside"  # inside outside
    y刻度位置 = "outside"  # inside outside
    
    
    show_x_Axis_border = T
    show_y_Axis_border = T
    colour_x_Axis_border = "black"
    colour_y_Axis_border = "black"
    size_x_Axis_border = 0.8
    size_y_Axis_border = 0.8
    show_panel_border =T
    panel_border_colour = "black"
    panel_border_size = 1
    
    
    bar_width =0.8
    bar_inner_width = 0
    bar_alpha = 1
    bar_border_size = 0.8
    bar_border_color = "black"
    bar_border_color_follow_bar = F
    
    
    bar_color_set = "Set1"
    bar_color_show_custom_color = F
    custom_colors1 = "grey"
    custom_colors2 = "grey"
    custom_colors3 = "grey"
    custom_colors4 = "grey"
    custom_colors5 = "grey"
    custom_colors6 = "grey"
    custom_colors7 = "grey"
    custom_colors8 = "grey"
    custom_colors9 = "grey"
    custom_colors10 = "grey"
    
    show_point = T
    point_jitter_width = 0.5
    point_alpha = 1
    point_size = 2
    point_shape = 16
    point_color = 'black'
    point_stroke = 1
    point_color_follow_bar = F
    
    show_errorbar = T
    error_bar_color_follow_bar = F
    errorbar_width = 0.3
    errorbar_size = 1
    error_bar_color = "black"
    
    show_sig_letter = T
    sig_letter_type = "group"  # "group" "all"
    sig_letter_level = 0.05
    sig_letter_method = "Duncan"  # "LSD" "Duncan" "TukeyHSD"
    letter_color = "black"
    letter_size =6
    letter_style = "plain" # "bold", "plain", "italic" and "bold.italic"
    letter_height_factor = 0.08
    letter_color_follow_bar = F
    
    show_sig_star = T
    sig_star_method = "wilcox_test"  # t检验(等方差) "t检验(等方差)" "wilcox_test" "kruskal检验"
    sig_padj_method = "holm"  # "holm" "hochberg" "hommel" "bonferroni" "BH" "BY" "fdr" "none"
    hide_ns = F
    star_or_pvalue = "p.adj.signif"  # "p", "p.adj" "p.signif", "p.adj.signif",
    sig_star_size = 6
    star_font_weight = "plain"  # "bold", "plain", "italic" and "bold.italic"
    star_line_type = 1
    star_line_tiplength = 0.03
    sig_star_color = "black"
    
    
    show_plot_background = F
    show_panel_background = F
    plot_background_color = "#339ACE"
    panel_background_color = "#EBEBEB"
    
    show_x_grid_line = F
    show_y_grid_line = F
    
    x_grid_line_color = "#FFFFFF"
    x_grid_line_size = 1
    
    y_grid_line_color = "#FFFFFF"
    y_grid_line_size = 1
    
    from_top_distance = 0.5
    from_bottom_distance = 0.1
    ylim_min = NA
    ylim_max = NA
    是否自定义y刻度 = F
    y刻度 = "0,1,5,8,15"
    
    format_y_number_style = ''  # 保留小数点后几位 %0.2f 保留两位小数 %.2e 科学计数法
    
    是否设置y轴断点 = F
    y轴断点下限 = 10
    y轴断点上限 = 40
    断区的宽度 = 0.1
    
    code_text = ''  # 代码文本
    
    show_average_point = T
    average_point_shape = 16
    average_point_size = 3
    average_point_color = "grey"
    average_point_stroke = 1
    
    ncol = 3
    strip_position = "top"  # 设置分面标题的位置 可选的值有"top", "bottom", "left", "right"
    scales_method_y = "free" # 固定坐标轴 可选的值有"fixed", "free", "free_x", "free_y"
    scales_method_x = "free" # 固定坐标轴 可选的值有"fixed", "free", "free_x", "free_y"
    strip_background_color = "lightgrey"
    strip_background_border_color = "black"
    strip_background_border_size = 1
    strip_text_color = "black"
    strip_text_size = 10
    strip_text_font_weight = "bold"
    show_strip_text = TRUE
    show_strip_background = T
    
    point_offset=0.4
    show_outlier_point = T
    outlier_shape = 16  # 不显示离群值
    outlier_size = 3
    outlier_color = "black"
    comparisons_method = "all_to_all"  # "t_test", "wilcox_test", "kruskal_test"
    
    show_letter_duiqi = F
    
    sig_star_offset = 0.2
    sig_star_interval = 0.5
    
    
    sig_letter_padj = 'holm'  # 显著性字母的p值校正方法
    
    color_method = 'group'   # group  Group
    show_gradient_color = F
    gradient_color_name = 'gradient16'
    custom_colors11 = "grey"
    custom_colors12 = "grey"
    custom_colors13 = "grey"
    custom_colors14 = "grey"
    custom_colors15 = "grey"
    custom_colors16 = "grey"
    custom_colors17 = "grey"
    custom_colors18 = "grey"
    custom_colors19 = "grey"
    custom_colors20 = "grey"
    
}

if (show_gradient_color){
    library(grDevices)  # 颜色渐变处理一下
    
    # gradient_func_path = './script/gradient_palettes.R'
    # 输出当前运行所在的位置，以确定相对路径的使用
    if (是否调试在Rstuiod) {
        gradient_func_path = './script/gradient_palettes.R'
    } else {
        gradient_func_path = './R_script/script/gradient_palettes.R'
    }
    print(getwd())
    source(gradient_func_path)   # 只需一次即可
    
    myPalette = get_palette_fun(gradient_color_name)  # 获取渐变色函数
}



# 读取数据

dat <- read.xlsx(input_file, 
                 sheet = input_file_sheet_num)  # 使用索引2来指定第二个工作表
dat <- as.data.frame(t(dat))  # 转置并强制转换为数据框
dat <- rownames_to_column(dat, var = "Group")  # 将行名变成第一列，列名设为 "RowNames"
# 假设 dat 是你的数据框
colnames(dat) <- dat[1, ]  # 将第一行设置为列名
dat <- dat[-1, ]           # 删除第一行
rownames(dat) <- NULL      # 可选：重置行名
# 转换第 2 列到最后一列为数值型
dat[, -1] <- lapply(dat[, -1], as.numeric)

dat_group = read.xlsx(input_group_file, 
                      sheet = input_group_file_sheet_num)  

names(dat)[1] <- "Group"  # 重命名列名
names(dat_group)[1] <- "SampleID"  # 重命名列名
names(dat_group)[2] <- "group"  # 重命名列名
# 将SampleID转换成字符类型
dat_group$SampleID <- as.character(dat_group$SampleID)  # 确保SampleID是字符类型

dat_long <- dat %>%
    pivot_longer(
        cols = -Group, # 排除Group列，将其他所有列转换为长格式
        names_to = "SampleID", # 新的列名变量
        values_to = "value", # 新的值变量
        names_prefix = "" # 移除列名前的前缀
    )%>%
    drop_na(value) # 删除value列中包含NA的行

# 合并之前确保SampleID一列是字符类型
dat_long$SampleID <- as.character(dat_long$SampleID)  # 确保SampleID是字符类型
# 确保dat_group的SampleID列也是字符类型
dat_group$SampleID <- as.character(dat_group$SampleID)  # 确保SampleID是字符类型

# 将分组信息与长格式数据合并
dat <- dat_long %>%
    left_join(dat_group, by = c("SampleID"))


# 设置因子水平，原因是后续作图的柱子排序问题 手动设置因子的水平
# dat$Group <-factor(dat$Group,level=c("Oct","Nov","Dec","Jan","Feb","Mar"))
# dat$group <-factor(dat$group,level=c("Control","ABA"))


# 确保作图的分组是因子水平，且按照原来的顺序
dat$Group <- factor(dat$Group, levels = unique(dat$Group))
dat$group <- factor(dat$group, levels = unique(dat$group))



##分组求均值（分组顺序至关重要）
dat_mean <- dat %>%
    group_by(Group, group) %>%
    dplyr::summarize(mean_data = mean(value, na.rm = T), sd = sd(value, na.rm = T),
                     n=sum(!is.na(value)), se = sd/sqrt(n))  # 保持group的原始顺序

##给均值添加显著性检验结果
Group <- unique(dat$Group)
out.1 <- data.frame()
for (i in Group){
    # 下面这个if语句可以解决某些特殊情况的数据缺失
    print(i)
    
    temp_data <- filter(dat, Group == i)
    # temp_data <- filter(dat, Group == "Oct")
    #选择最小显著差异法，可修改======================================================
    if (sig_letter_method == "LSD") {
        lsd_test <- LSD.test(lm(value ~ group, temp_data), 'group',p.adj = sig_letter_padj , alpha = sig_letter_level)
        test <- lsd_test
    } else if (sig_letter_method == "TukeyHSD") {
        # 安装并加载agricolae包，进行HSD检验
        library(agricolae)
        # 进行HSD测试
        hsd_test <- HSD.test(lm(value ~ group, temp_data),'group', console = T, alpha = sig_letter_level)
        test <- hsd_test
    } else if (sig_letter_method == "Duncan") {
        duncan_test <- duncan.test(lm(value ~ group, temp_data),'group', alpha = sig_letter_level)
        test <- duncan_test
    } else if (sig_letter_method == "Dunn") {
        # 计算中位数并排序
        medians <- temp_data %>%
            group_by(group) %>%
            summarise(median_value = median(value, na.rm = TRUE)) %>%
            arrange(desc(median_value))
        # 根据中位数排序后的组别重新排列数据
        temp_data <- temp_data %>%
            mutate(group = factor(group, levels = medians$group))
        
        pairwise_p <- temp_data %>% dunn_test(value ~ group, p.adjust.method = sig_letter_padj )
        
        library(multcompView)
        # 提取p值并命名（格式：group1-group2）
        p_values <- setNames(
            pairwise_p$p.adj,
            paste(pairwise_p$group1, pairwise_p$group2, sep = "-")
        )
        
        # 生成显著性字母标记（使用0.05作为显著性阈值）
        groups <- multcompLetters(p_values, threshold = sig_letter_level)$Letters
        
    } else if (sig_letter_method == "wilcox") {
        # 计算中位数并排序
        medians <- temp_data %>%
            group_by(group) %>%
            summarise(median_value = median(value, na.rm = TRUE)) %>%
            arrange(desc(median_value))
        # 根据中位数排序后的组别重新排列数据
        temp_data <- temp_data %>%
            mutate(group = factor(group, levels = medians$group))
        
        pairwise_p <- temp_data %>%
            wilcox_test(value ~ group,p.adjust.method = sig_letter_padj ) 
        if (!"p.adj" %in% colnames(pairwise_p)) {
            pairwise_p <- pairwise_p %>% 
                mutate(p.adj = p)  # 创建 p.adj 列，值等于 p
        }
        library(multcompView)
        
        # 提取p值并命名（格式：group1-group2）
        p_values <- setNames(
            pairwise_p$p.adj,
            paste(pairwise_p$group1, pairwise_p$group2, sep = "-")
        )
        
        # 生成显著性字母标记（使用0.05作为显著性阈值）
        groups <- multcompLetters(p_values, threshold = sig_letter_level)$Letters
        
    } else {
        lsd_test <- LSD.test(lm(value ~ group, temp_data),'group', p.adj = sig_letter_padj, alpha = sig_letter_level)
        test <- lsd_test
    }
    
    # test <- LSD.test(lm(value ~ group, data), 'group', console = T, alpha = 0.05)
    
    if (sig_letter_method == "Dunn" || sig_letter_method == "wilcox" ) {
        
        # original_order <- factor(temp_data$group, levels = unique(temp_data$group) )
        # # 创建 plotdata，确保顺序与 original_order 一致
        # plotdata <- data.frame(
        #     group = levels(original_order),  # 保持原始顺序
        #     marker = sig_letters[levels(original_order)]  # 按 original_order 顺序提取
        # )
        
        data1 <- data.frame(groups,  Group = i)
        data11 <- cbind(group = row.names(data1), data1)
        # 1. 计算每个 group 的平均值
        mean_vals <- temp_data %>%
            group_by(Group, group) %>%
            summarise(value = mean(value, na.rm = TRUE), .groups = "drop")
        
        # 2. 合并到 data1
        data11 <- data11 %>%
            left_join(mean_vals, by = c("Group", "group"))
        
        out.1 <- rbind(out.1, data11, make.row.names = F)
        
        
    } else {
        data1 <- data.frame(test$groups,  Group = i)
        data11 <- cbind(group = row.names(data1), data1)
        out.1 <- rbind(out.1, data11, make.row.names = F)
    }
}


#将结果返回分组均值数据框
dat_mean <- merge(dat_mean, out.1, by = c('Group','group'))
# 删除value一列的值
dat_mean <- subset(dat_mean, select = -value)  # 删除value列



# 为了后面的整体显著性分析，需要将Group_groupd列转换为因子类型
# 下面是创建一个新的列来标记每一个小分组的名称，用于后面的整体显著性分析
dat <- dat %>%
    mutate(Group_group = factor(paste0(Group, "_", group)))
# 在data——mean中创建：
dat_mean <-  dat_mean %>%
    mutate(Group_group = factor(paste0(Group, "_", group)))

# 先将LSD方法注释一下
##给均值添加显著性检验结果
if (sig_letter_method == "LSD") {
    lsd_test <- LSD.test(lm(value ~ Group_group, dat), 'Group_group',p.adj = sig_letter_padj, alpha = sig_letter_level)
    test_Group_group <- lsd_test
} else if (sig_letter_method == "TukeyHSD") {
    # 安装并加载agricolae包，进行HSD检验
    library(agricolae)
    # 进行HSD测试
    hsd_test <- HSD.test(lm(value ~ Group_group, dat),'Group_group', console = T, alpha = sig_letter_level)
    test_Group_group <- hsd_test
} else if (sig_letter_method == "Duncan") {
    duncan_test <- duncan.test(lm(value ~ Group_group, dat),'Group_group', alpha = sig_letter_level)
    test_Group_group <- duncan_test
    
}else if (sig_letter_method == "Dunn") {
    
    # 计算中位数并排序
    medians <- dat %>%
        group_by(Group_group) %>%
        summarise(median_value = median(value, na.rm = TRUE)) %>%
        arrange(desc(median_value))
    # 根据中位数排序后的组别重新排列数据
    dat <- dat %>%
        mutate(Group_group = factor(Group_group, levels = medians$Group_group))
    
    pairwise_p <- dat %>% dunn_test(value ~ Group_group, p.adjust.method = sig_letter_padj )
    
    library(multcompView)
    # 提取p值并命名（格式：group1-group2）
    p_values <- setNames(
        pairwise_p$p.adj,
        paste(pairwise_p$group1, pairwise_p$group2, sep = "-")
    )
    
    # 生成显著性字母标记（使用0.05作为显著性阈值）
    groups <- multcompLetters(p_values, threshold = sig_letter_level)$Letters
    
    # names(cld) <- c("Group", "cld")
}else if (sig_letter_method == "wilcox") {
    # 计算中位数并排序
    medians <- dat %>%
        group_by(Group_group) %>%
        summarise(median_value = median(value, na.rm = TRUE)) %>%
        arrange(desc(median_value))
    # 根据中位数排序后的组别重新排列数据
    dat <- dat %>%
        mutate(Group_group = factor(Group_group, levels = medians$Group_group))
    
    pairwise_p <- dat %>% wilcox_test(value ~ Group_group, p.adjust.method = sig_letter_padj )
    
    library(multcompView)
    # 提取p值并命名（格式：group1-group2）
    p_values <- setNames(
        pairwise_p$p.adj,
        paste(pairwise_p$group1, pairwise_p$group2, sep = "-")
    )
    
    # 生成显著性字母标记（使用0.05作为显著性阈值）
    groups <- multcompLetters(p_values, threshold = sig_letter_level)$Letters
    
}else {
    
    lsd_test <- LSD.test(lm(value ~ Group_group, dat),'Group_group', p.adj = sig_letter_padj, alpha = sig_letter_level)
    test_Group_group <- lsd_test
}

# 图型绘制处理# ================================================================================
if (sig_letter_method == "Dunn" || sig_letter_method == "wilcox" ) {
    
    # original_order <- factor(data$group, levels = unique(data$group))
    # # 创建 plotdata，确保顺序与 original_order 一致
    # plotdata <- data.frame(
    #     group = levels(original_order),  # 保持原始顺序
    #     marker = sig_letters[levels(original_order)]  # 按 original_order 顺序提取
    # )
    
    data2 <- data.frame(groups)
    data2 <- cbind(Group_group = row.names(data2), data2)
    colnames(data2)[2]<- "mark_Group_group"
    # colnames(data2)[1]<- "Group_group"
} else {
    data2 <- data.frame(test_Group_group$groups)
    data2 <- cbind(Group_group = row.names(data2), data2)
    colnames(data2)[3] <- "mark_Group_group"   # 重命名这一列的列名，避免和上面的那个重复 
}

#将结果返回分组均值数据框
dat_mean <- merge(dat_mean, data2, by = c('Group_group'))


# 分组计算每个组的最大值
max_values <- dat %>%
    group_by(Group,group) %>%
    summarise(max_value = max(value),
              .groups = "drop")
min_values <- dat %>%
    group_by(Group,group) %>%
    summarise(min_value = min(value),
              .groups = "drop")

# 计算中位数
median <- dat %>%
    group_by(Group,group) %>%
    summarise(median_value = median(value, na.rm = TRUE),
              .groups = "drop")

# 合并数据
dat_mean <- dat_mean %>%
    left_join(max_values, by = c("Group","group")) %>%
    left_join(min_values, by = c("Group","group")) %>%
    left_join(median, by = c("Group","group"))


if (color_method=='group') {
    color_length = length(unique(dat$group))  # 获取分组的数量
} else if (color_method=='Group') {
    color_length = length(unique(dat$Group))  # 获取分组的数量
}

if(bar_color_show_custom_color){
    bar_color = c(custom_colors1,
                  custom_colors2,
                  custom_colors3,
                  custom_colors4,
                  custom_colors5,
                  custom_colors6,
                  custom_colors7,
                  custom_colors8,
                  custom_colors9,
                  custom_colors10,
                  custom_colors11,
                  custom_colors12,
                  custom_colors13,
                  custom_colors14,
                  custom_colors15,
                  custom_colors16,
                  custom_colors17,
                  custom_colors18,
                  custom_colors19,
                  custom_colors20)
    
    bar_color = bar_color[1:color_length]   # 截取与数据长度相同的颜色,不然会报错
} else if (show_gradient_color){
    bar_color = myPalette(color_length )
    
}  else {# 控制柱子边框颜色，使用系统的显色板
    library(RColorBrewer)  # 用于提取颜色rbrewer.pal(7, "Set2")
    # 假设df是你的数据框，column_name是你想要统计的列名
    if (color_length<3){
        bar_color = brewer.pal(3, bar_color_set)
        bar_color = bar_color[1:color_length]} else {
            bar_color = brewer.pal(color_length, bar_color_set)}
}


# 分面scale控制
if (scales_method_x == 'free' & scales_method_y == 'free') {
    scales_method = "free"
} else if (scales_method_x == 'fixed' & scales_method_y == 'free'){
    scales_method = "free_y"
} else if (scales_method_x == 'free' & scales_method_y == 'fixed'){
    scales_method = "free_x"
} else if (scales_method_x == 'fixed' & scales_method_y == 'fixed'){
    scales_method = "fixed"
} else {
    scales_method = "fixed"
}
# print(scales)

if (!show_outlier_point) {
    outlier_shape = NA
}





# 基础绘图----
# group列设置为因子类型
dat$group <- factor(dat$group, levels = unique(dat$group))  # 确保group列是因子类型，并按照原来的顺序
dat$Group <- factor(dat$Group, levels = unique(dat$Group))  # 确保group列是因子类型，并按照原来的顺序

p = ggplot(dat, aes( x = group, y= value, fill =  get(color_method)  )) +
    facet_wrap(~Group, 
               ncol = ncol,
               scales = scales_method,
               strip.position = strip_position,
    ) +  # 做个分面图
    # geom_bar(
    geom_boxplot(
        stat = "boxplot",
        position = position_dodge(width = bar_width), 
        width = bar_width-bar_inner_width,
        color = bar_border_color,
        alpha = bar_alpha,
        linewidth = bar_border_size,
        outlier.shape = outlier_shape,  # 不显示离群值
        outlier.size = outlier_size, 
        outlier.color = outlier_color
    )






if (bar_border_color_follow_bar) {
    
    p = ggplot(dat, aes(group, value, fill = get(color_method)  )) +
        facet_wrap(~Group, 
                   ncol = ncol,
                   scales = scales_method,
                   strip.position = strip_position,) +  # 做个分面图
        geom_boxplot(
            stat = "boxplot",
            position = position_dodge(width = bar_width), 
            width = bar_width-bar_inner_width,
            aes(color = group),
            alpha = bar_alpha,
            linewidth = bar_border_size,
            show.legend = FALSE,
            outlier.shape = outlier_shape,  # 不显示离群值
            outlier.size = outlier_size, 
            outlier.color = outlier_color
        ) + 
        scale_color_manual(values = bar_color)
}

# 误差线----
if (show_errorbar) {
    
    if (error_bar_color_follow_bar) {
        p = p+ stat_boxplot(geom ="errorbar", 
                            position = position_dodge(bar_width),
                            linewidth = errorbar_size,
                            width =errorbar_width,
                            aes(color = group),
                            show.legend = FALSE,
        ) + 
            scale_color_manual(values = bar_color)
    } else {
        p = p+ stat_boxplot(geom ="errorbar", 
                            position = position_dodge(bar_width),
                            linewidth = errorbar_size, 
                            width =errorbar_width, 
                            color =error_bar_color)}
    
    if (bar_border_color_follow_bar) {
        p = p +geom_boxplot(
            # stat = "summary", 
            position = position_dodge(width = bar_width),
            # fun = mean,
            width = bar_width-bar_inner_width,
            aes(color = group),
            alpha = bar_alpha,
            linewidth = bar_border_size,
            show.legend = FALSE,
            outlier.shape = outlier_shape,  # 不显示离群值
            outlier.size = outlier_size, 
            outlier.color = outlier_color
        ) + 
            scale_color_manual(values = bar_color)
    } else {
        p = p +geom_boxplot(
            # stat = "summary", 
            position = position_dodge(width = bar_width),
            # fun = mean,
            width = bar_width-bar_inner_width,
            linewidth = bar_border_size,
            show.legend = FALSE,
            colour = bar_border_color,
            alpha = bar_alpha,
            outlier.shape = outlier_shape,  # 不显示离群值
            outlier.size = outlier_size, 
            outlier.color = outlier_color
        )
    }
}



# 柱子颜色----
p = p + scale_fill_brewer(palette = bar_color_set,name = custom_legend_title_name)  # 设置填充颜色)

if (bar_color_show_custom_color) {
    p = p + scale_fill_manual(values = c(custom_colors1,
                                         custom_colors2,
                                         custom_colors3,
                                         custom_colors4,
                                         custom_colors5,
                                         custom_colors6,
                                         custom_colors7,
                                         custom_colors8,
                                         custom_colors9,
                                         custom_colors10,
                                         custom_colors11,
                                         custom_colors12,
                                         custom_colors13,
                                         custom_colors14,
                                         custom_colors15,
                                         custom_colors16,
                                         custom_colors17,
                                         custom_colors18,
                                         custom_colors19,
                                         custom_colors20),
                              name = custom_legend_title_name)
} else if (show_gradient_color) {
    p = p + scale_fill_manual(values = bar_color, name = custom_legend_title_name)
} 


# 初始的主题----
p = p + theme_classic() # 设置经典的主题

# 000基础配置区域----
# 设置临时的字体样式
if (font_Style == "Arial") {
    font_style_set = "sans"    # Arial字体
} else {
    font_style_set = "serif"    # 新罗马字体 Times New Roman
}

# 简单参数处理
# 设置x文本对齐方式
if (axis_text_x_Alignment == "middle") {
    set_axis_text_x_Alignment = 0.5
} else if (axis_text_x_Alignment == "left") {
    set_axis_text_x_Alignment = 0
} else if (axis_text_x_Alignment == "right") {
    set_axis_text_x_Alignment = 1
}
if (axis_text_y_Alignment == "middle") {
    set_axis_text_y_Alignment = 0.5
} else if (axis_text_y_Alignment == "left") {
    set_axis_text_y_Alignment = 0
} else if (axis_text_y_Alignment == "right") {
    set_axis_text_y_Alignment = 1
}
if (axis_text_x_angle==90){
    set_axis_text_x_Alignment_vjust = 0.5
} else {
    set_axis_text_x_Alignment_vjust = 1
} 
p = p +
    theme(
        plot.background = element_rect(fill = "white"), # 设置绘图区域背景颜色
        
        text = element_text(family = font_style_set,colour = 'black'),  # 设置所有文本的字体和颜色
        
        # 设置坐标轴标题的字体大小和位置
        axis.title.x = element_text(family = font_style_set, size = Size_x_title,, face = x_title_font_weight, color = x_title_color, hjust = 0.5,vjust = 0.5),
        axis.title.y = element_text(family = font_style_set, size = Size_y_title, hjust = 0.5,vjust = 0.5, face = y_title_font_weight, color = y_title_color),
        
        # 设置坐标轴标题的字体大小和位置
        axis.text.x = element_text(family = font_style_set, size = Size_x_Axis,  angle = axis_text_x_angle, hjust = set_axis_text_x_Alignment, vjust = set_axis_text_x_Alignment_vjust, color = x_Axis_color, face = x_Axis_font_weight),
        axis.text.y = element_text(family = font_style_set, size = Size_y_Axis,  hjust = set_axis_text_y_Alignment,vjust = 0.5, color = y_Axis_color, face = y_Axis_font_weight, angle = axis_text_y_angle),
        
        
        # 设置标题的字体大小、加粗、颜色和垂直位置
        plot.title = element_text(family = font_style_set, hjust = 0.5, vjust = 0.5,size = title_size, face = title_font_weight, color = title_color),  # 设置标题居中、字体大小、加粗、颜色和垂直位置
        
        # 图例的设置
        legend.title = element_text(family = font_style_set,size=legend_title_font_size,face=legend_title_font_weight,color=legend_title_color),  # 设置图例标题的字体
        legend.text = element_text(family = font_style_set,size=legend_text_font_size,face=legend_text_font_weight,color=legend_text_color)  # 设置图例文本的字体
    ) 


# 刻度----

if (x刻度位置=="inside"){
    x_刻度长度_set = -x_刻度长度
} else {x_刻度长度_set = x_刻度长度}
if (y刻度位置=="inside"){
    y_刻度长度_set = -y_刻度长度
} else { y_刻度长度_set = y_刻度长度}


if (show_x_刻度){
    p <- p + theme(
        axis.ticks.x = element_line(color = x_刻度颜色, size = x_刻度粗细),  # x轴刻度线
        axis.ticks.length.x = unit(x_刻度长度_set, "cm"),  # 刻度线的长度
    )
} else {
    p <- p + theme(
        axis.ticks.x = element_blank(),
    )
}


if (show_y_刻度){
    p <- p + theme(
        axis.ticks.y = element_line(color = y_刻度颜色, size = y_刻度粗细),   # y轴刻度线
        axis.ticks.length.y = unit(y_刻度长度_set, "cm"),  # 刻度线的长度
    )
} else {
    p <- p + theme(
        axis.ticks.y = element_blank()
    )
}

# XY边框----
if (show_panel_border){
    p <- p +
        theme(
            panel.border = element_rect(colour = panel_border_colour, fill = NA, linewidth = panel_border_size),  # 设置面板边框的颜色、填充和粗细
            axis.line.y = element_blank(), # y轴（底部）的粗细
            axis.line.x = element_blank() # x轴（底部）的粗细
        )
} else {
    if (show_x_Axis_border && show_y_Axis_border){
        p <- p +
            theme(
                axis.line.x = element_line(colour = colour_x_Axis_border, linewidth = size_x_Axis_border),  # x轴（底部）的粗细
                axis.line.y = element_line(colour = colour_y_Axis_border, linewidth = size_y_Axis_border),  # y轴（左侧）的粗细
            )
    }else if (show_x_Axis_border&& !show_y_Axis_border){
        p <- p +
            theme(
                axis.line.x = element_line(colour = colour_x_Axis_border, linewidth = size_x_Axis_border),  # x轴（底部）的粗细
                axis.line.y = element_blank() # x轴（底部）的粗细
            )
    }else if (show_y_Axis_border && !show_x_Axis_border){
        p <- p +
            theme(
                axis.line.y = element_line(colour = colour_y_Axis_border, linewidth = size_y_Axis_border),  # y轴（左侧）的粗细
                axis.line.x = element_blank() # x轴（底部）的粗细
            )
    }else if (!show_y_Axis_border && !show_x_Axis_border){
        p <- p +
            theme(
                axis.line.x = element_blank(), # x轴（底部）的粗细  
                axis.line.y = element_blank() # y轴（左侧）的粗细
            )
    }
    
}




# 样本点----
if (show_point) {
    dat$group_numeric <- as.numeric(factor(dat$group))
    if (point_color_follow_bar) {
        p = p + geom_point(data = dat, aes(x = group_numeric+point_offset,y = value, color = group), 
                           position = position_jitterdodge(jitter.width = point_jitter_width, dodge.width = bar_width), 
                           alpha = point_alpha,
                           size = point_size, 
                           shape = point_shape,
                           # color = point_color,
                           stroke= point_stroke,
                           show.legend = F) +
            scale_color_manual(values = bar_color)  # 手动设置颜色序列
        
    } else {
        p = p + geom_point(data = dat, aes(x = group_numeric+point_offset,y = value), 
                           position = position_jitterdodge(jitter.width = point_jitter_width, dodge.width = bar_width), 
                           alpha = point_alpha,
                           size = point_size, 
                           shape = point_shape,
                           color = point_color,
                           stroke= point_stroke,
                           show.legend = F
        )  # 添加样本点
    }
    
}



# 字母标记----
# p = p + geom_text(data = dat_mean, aes(y = (mean_data + SD)*1.03, x = Group, group = group, label = mark_Group_group),
#                   position = position_dodge(0.6), 
#                   size = 4,
#                   family = "serif"  # 设置字体
# )
if (sig_letter_type == "group") {
    letter_label = "groups"
} else if (sig_letter_type == "all") {
    letter_label = "mark_Group_group"}


if (show_sig_letter) {
    
    # 第一步：按分面变量分组计算每个分面内的局部范围
    dat_mean <- dat_mean %>%
        group_by(Group) %>%  # 将"分面变量"替换为你的实际分面列名（如：facet_column）
        mutate(
            local_max = max(max_value),
            local_min = min(min_value),
            letter_y_position = max_value + (local_max - local_min) * letter_height_factor
        ) %>%
        ungroup()
    
    # 判断是否对齐
    if (show_letter_duiqi) {
        dat_mean <- dat_mean %>%
            group_by(Group) %>%
            mutate(letter_y_position = max(letter_y_position, na.rm = TRUE)) %>%
            ungroup()
    }
    
    if (letter_color_follow_bar) {
        p = p + geom_text(data = dat_mean, 
                          aes(x = group, 
                              y = letter_y_position,
                              group = group, 
                              label = eval(parse(text = letter_label)),
                              color = group),
                          
                          position = position_dodge(bar_width), 
                          size = letter_size,
                          fontface = letter_style,
                          family = font_style_set,
                          show.legend = FALSE,)+  # 设置字体
            scale_color_manual(values = bar_color)  # 手动设置颜色序列
        
    } else {p = p + geom_text(data = dat_mean, 
                              aes(x = group, 
                                  y = letter_y_position,
                                  group = group, 
                                  label = eval(parse(text = letter_label)),
                              ),
                              
                              position = position_dodge(bar_width), 
                              size = letter_size,
                              color = letter_color,
                              fontface = letter_style,
                              family = font_style_set ,
                              show.legend = FALSE,)  # 设置字体
    }
}


# star标记----
if (show_sig_star) {
    library(ggpubr)   # stat_pvalue_manual
    library(rstatix)   # add_xy_position函数要使用这个包
    
    from_top_distance = from_top_distance + 0.1
    
    if (comparisons_method=='first_to_all'){
        # 构建比较的分组信息
        # 获取唯一分组
        groups <- unique(dat$group)
        # 生成所有两两组合
        all_combinations <- combn(groups, 2, simplify = FALSE)
        # 将所有组合转换为字符向量，去除因子水平
        all_combinations <- lapply(all_combinations, function(x) as.character(x))
        
        # 截取前 length(groups) - 1 项
        first_to_all_comparisons <- all_combinations[1:(length(groups) - 1)]
        comparisons_set = first_to_all_comparisons
    } else { comparisons_set = NULL }
    
    
    
    if (sig_star_method == "t检验(等方差)") { 
        data_sig <- dat %>%
            group_by(Group) %>%
            t_test(value ~ group,p.adjust.method = sig_padj_method,var.equal = T,paired = FALSE,comparisons = comparisons_set,) %>%
            add_significance("p") %>%
            add_xy_position(x = "group", scales  = "free")
    } else if (sig_star_method == "t检验(不等方差)") {
        data_sig <- dat %>%
            group_by(Group) %>%
            t_test(value ~ group,p.adjust.method = sig_padj_method,var.equal = F,paired = FALSE,comparisons = comparisons_set,) %>%
            add_significance("p") %>%
            add_xy_position(x = "group", scales  = "free")
        
    } else if (sig_star_method == "wilcox_test") {
        data_sig <- dat %>%
            group_by(Group) %>%
            wilcox_test(value ~ group,p.adjust.method = sig_padj_method,comparisons = comparisons_set,) %>%
            add_significance("p") %>%
            add_xy_position(x = "group", scales  = "free")
    } 
    
    
    # 分组计算的： 调整连线的高度和间隔
    # 假设 data_sig 是你的数据框 对内部间隔进行调整
    # if (nrow(data_sig) > 1) {
    #     # 按group分组处理
    #     data_sig <- data_sig %>%
    #         group_by(Group) %>%
    #         mutate(
    #             y_positions = sort(y.position),  # 确保排序
    #             n = n(),
    #             # 只在组内有多行时计算
    #             avg_interval = ifelse(n > 1, mean(diff(y_positions)), NA),
    #             # 生成新位置
    #             new_y.position = ifelse(!is.na(avg_interval),
    #                                     first(y.position) + (0:(n()-1)) * avg_interval * sig_star_interval,
    #                                     y.position)
    #         ) %>%
    #         ungroup() %>%
    #         # 使用新位置替换原位置
    #         mutate(y.position = new_y.position) %>%
    #         select(-y_positions, -n, -avg_interval, -new_y.position)
    # } else {
    #     print("数据框只有1行，跳过计算。")
    # }
    
    # 在data_sig中加入最大值和最小值 为了统一使用相同的间距，在不同的分面中
    # 1. 从 max_values 提取每组最大值（按 Group） 
    group_max <- max_values %>%
        group_by(Group) %>%
        summarise(max_value = max(max_value))  # 如果每组只有一个最大值，直接用原始数据
    
    # 2. 将最大值合并到 data_sig
    data_sig <- data_sig %>%
        left_join(group_max, by = "Group")  # 按 Group 匹配
    
    # 3. 同理合并最小值（如果有 min_values 数据框）
    # 假设 min_values 结构与 max_values 相同
    group_min <- min_values %>%  # 替换为你的最小值数据框
        group_by(Group) %>%
        summarise(min_value = min(min_value))
    
    data_sig <- data_sig %>%
        left_join(group_min, by = "Group")
    
    if (nrow(data_sig) > 1) {
        # 按group分组处理
        data_sig <- data_sig %>%
            group_by(Group) %>%
            mutate(
                y_positions = sort(y.position),  # 确保排序
                n = n(),
                # 只在组内有多行时计算
                avg_interval = ifelse(n > 1, mean(diff(y_positions)), NA),
                avg_interval2 = mean(max_value - min_value, na.rm = TRUE),  # 计算每组的平均间隔
                # 生成新位置
                new_y.position = ifelse(!is.na(avg_interval),
                                        first(y.position) + (0:(n()-1)) * avg_interval2 * sig_star_interval*0.08,
                                        y.position)
            ) %>%
            ungroup() %>%
            # 使用新位置替换原位置
            mutate(y.position = new_y.position) %>%
            select(-y_positions, -n, -avg_interval, -new_y.position)
    } else {
        print("数据框只有1行，跳过计算。")
    }
    
    
    
    # 调整整体的高度
    data_sig <- data_sig %>%
        group_by(Group) %>%
        mutate(
            group_min = min(dat$value[dat$Group == cur_group()$Group]),  # 当前组的最小值
            group_max = max(dat$value[dat$Group == cur_group()$Group]), # 当前组的最大值
            y.position = ifelse(
                group_min < 0,
                y.position + sig_star_offset * (group_max - group_min),  # 有负值，用范围调整
                y.position + sig_star_offset * (group_max - group_min)   # 无负值，用最大值调整
            )
        ) %>%
        ungroup() %>%
        select(-group_min, -group_max)  # 移除临时列
    
    
    p = p + stat_pvalue_manual(
        data = data_sig,
        label = star_or_pvalue,    # 显著性标记 星号还是数字 选项有"p", "p.adj" "p.signif", "p.adj.signif",
        tip.length =star_line_tiplength,   # 显著性标记向下伸长的长度
        label.size = sig_star_size,
        
        color = sig_star_color,
        linetype = star_line_type,
        hide.ns = hide_ns,
        inherit.aes = F,
        family = font_style_set,
        fontface = star_font_weight,
    )
    
}



# data_sig_wilcox <- dat %>%
#     group_by(Group) %>%
#     wilcox_test(value ~ group,p.adjust.method = "holm") %>%
#     add_significance("p") %>%
#     add_xy_position(x = "Group")


# data_sig_kruskal <- dat %>%
#     group_by(Group) %>%
#     kruskal_test(value ~ group) %>%
#     add_significance("p") %>%
#     add_xy_position(x = "Group")

# data_sig_t_test <- dat %>%
#     group_by(Group) %>%
#     t_test(value ~ group,p.adjust.method = "holm",) %>%
#     add_significance("p") %>%
#     add_xy_position(x = "Group")


# p+ stat_pvalue_manual(
#     data = data_sig_t_test,
#     label = "p.adj.signif",    # 显著性标记 星号还是数字 选项有"p", "p.adj" "p.signif", "p.adj.signif",
#     tip.length = 0.03,   # 显著性标记向下伸长的长度
#     bracket.nudge.y = 0,  # 显著性的高低位置
#     label.size = 6,
# 
#     color = "black",
#     linetype = 1,
#     hide.ns = F,
#     inherit.aes = F,
#     family = font_style_set,
#     fontface = 'plain',
# )



# 标题----
if (show_title){
    p = p+ ggtitle(title_name)   # 设置标题
}

# 图例----
if (show_legend) {
    if (legend_position == "inside") {
        p <- p + theme(
            legend.position = c(inside_legend_x, inside_legend_y),
            legend.direction = legend_direction,
            
        )
    } else {
        p <- p + theme(
            legend.position = legend_position,
            legend.direction = legend_direction,
            
        )
    }
} else {
    p <- p + theme(legend.position = 'none') # 如果show_legend为FALSE，则隐藏图例
}
# p = p +guides(
#     # fill = guide_legend(override.aes = list(color = NA)),  # 去除填充颜色图例中的点
#     # color = guide_legend(override.aes = list(fill = NA))   # 去除边框颜色图例中的色块
# )


# 10x轴y轴标题----
if(x_title_text ==''){set_x_title_text = "" } else {set_x_title_text = x_title_text}
if(y_title_text ==''){set_y_title_text = "" } else {set_y_title_text = y_title_text}

p <- p + labs(
    x = if (show_x_title) set_x_title_text else NULL,  # 使用NULL代替空字符串来确保不显示任何x轴标题
    y = if (show_y_title) set_y_title_text else NULL,   # 使用NULL代替空字符串来确保不显示任何y轴标题
    
)

# 背景网格线----
if (show_plot_background) {
    p = p + theme(plot.background = element_rect(fill = plot_background_color),  # 设置绘图区域背景颜色
    )
} else {
    p = p + theme(plot.background = element_rect(fill = NA),  # 设置绘图区域背景颜色
    )
}

if (show_panel_background) {
    p = p + theme(
        panel.background = element_rect(fill = panel_background_color),  # 设置面板背景颜色
    )
} else {
    p = p + theme(
        panel.background = element_rect(fill = NA),  # 设置面板背景颜色
    )
}

if (show_x_grid_line) {
    p = p + theme(
        panel.grid.major.x = element_line(colour = x_grid_line_color, linewidth = x_grid_line_size),  # 设置主要网格线
        panel.grid.minor.x = element_blank()  # 设置次要网格线
    )
} else {
    p = p + theme(
        panel.grid.major.x = element_blank(),  # 设置主要网格线
        panel.grid.minor.x = element_blank()  # 设置次要网格线
    )
}

if (show_y_grid_line) {
    p = p + theme(
        panel.grid.major.y = element_line(colour = y_grid_line_color, linewidth = y_grid_line_size),  # 设置主要网格线
        panel.grid.minor.y = element_blank()  # 设置次要网格线
    )
} else {
    p = p + theme(
        panel.grid.major.y = element_blank(),  # 设置主要网格线
        panel.grid.minor.y = element_blank()  # 设置次要网格线
    )
}


# 14断点----
if (是否设置y轴断点){
    library(ggbreak)
    p = p+
        scale_y_break(c(y轴断点下限, y轴断点上限), space = 断区的宽度) +
        theme(axis.title.y = element_text(angle = 90),
              axis.line.y.right = element_blank(),  # 移除右侧Y轴的线
              axis.ticks.y.right = element_blank(),  # 移除右侧Y轴的刻度
              axis.text.y.right = element_blank()  # 移除右侧Y轴的刻度文本
        )
}




# p <- p + coord_cartesian(ylim = c(set_ylim_min, set_ylim_max))+
#     scale_y_continuous(expand=c(0,0))



# 小数位数----
if (format_y_number_style == '') {
    format_y_number_style='%g'
}



# y轴范围----
if (scales_method == 'free' |  scales_method == 'free_y') {
    # 修改您的ggplot代码
    # p + facetted_pos_scales(
    #     y = list(
    #         group == "ABA" ~ scale_y_continuous(limits = c(0, 15),expand=c(0,0)),
    #         group == "WT" ~ scale_y_continuous(limits = c(0, 50),expand=c(0,0)),
    #         group == "Control" ~ scale_y_continuous(limits = c(0, 75),expand=c(0,0))
    #                                                 
    #     )
    # )
    
    library(ggh4x)
    # 初始化一个空列表，用于存储 scale_y_continuous 表达式
    scale_list <- list()
    # 循环遍历每个 group
    for (i in Group) {
        # 过滤当前 group 的数据
        temp_data <- filter(dat_mean, Group == i)
        
        # 计算 mean_data 的最大值和最小值
        temp_max_mean <- max(temp_data$max_value)
        temp_min_mean <- min(temp_data$min_value)
        
        set_ylim_max = temp_max_mean + (temp_max_mean-temp_min_mean)*(from_top_distance)
        set_ylim_min = temp_min_mean - (temp_max_mean-temp_min_mean)*(from_bottom_distance)
        
        
        # 生成 scale_y_continuous 表达式并添加到列表中
        scale_expr <- paste0(
            'Group == "', i, '" ~ scale_y_continuous(limits = c(', 
            set_ylim_min, ', ', set_ylim_max, '),labels = function(x) sprintf(format_y_number_style, x), expand = c(0, 0))'
        )
        
        # 将表达式添加到列表
        scale_list <- append(scale_list, scale_expr)
    }
    
    # 将列表转换为字符串并拼接为完整的表达式
    scale_expr_final <- paste0("list(", paste(scale_list, collapse = ", "), ")")
    
    p = p + facetted_pos_scales(
        y = eval(parse(text = scale_expr_final))  # 解析并应用生成的表达式
    )
} else {
    
    if (  is.na(ylim_min) && is.na(ylim_max)){
        
        # 设置y轴的范围,如果大于零就按照0为底部计算，如果有平均值小于0就按照平均值为底部计算
        set_ylim_min = min(dat_mean$min_value) - (max(dat_mean$max_value)-min(dat_mean$min_value))*(from_bottom_distance)
        set_ylim_max = max(dat_mean$max_value) + (max(dat_mean$max_value)-min(dat_mean$min_value))*(from_top_distance)
        
    }else{
        ylim_min = as.numeric(ylim_min)
        ylim_max = as.numeric(ylim_max)
        set_ylim_min = ylim_min
        set_ylim_max = ylim_max
    }
    
    p = p + coord_cartesian(ylim = c(set_ylim_min, set_ylim_max))+
        scale_y_continuous(
            labels = function(x) sprintf(format_y_number_style, x),
            expand=c(0,0)
        )  # 设置y轴的范围扩展
}



# 自定义y轴的刻度数值----要放在设置y轴的范围之后
if (是否自定义y刻度){
    # y刻度 = "0,1,5,8,15"
    
    # 使用strsplit函数将字符串分割成单独的数字
    num_list <- unlist(strsplit(y刻度, ","))
    
    # 将分割后的字符向量转换为数值向量
    y自定义刻度 <- as.numeric(num_list)
    p = p +
        scale_y_continuous(
            breaks = y自定义刻度,  # 指定刻度位置
            # expand=c(bar_bottom_to_axis/100,0)
            expand=c(0,0),  # 设置y轴的范围扩展
            labels = function(x) sprintf(format_y_number_style, x),  # 小数位数
        )
}


# 设置绘图区域的边距
# p <- p + theme(plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))  # 设置绘图区域的边距

# 平均值点----
if (show_average_point) {
    p = p+  stat_summary(data = dat_mean, 
                         # fun = mean, 
                         geom = "point", 
                         position = position_dodge(width = bar_width),
                         aes(x = group, y = mean_data,
                             group = group),
                         shape = average_point_shape, 
                         size = average_point_size, 
                         color = average_point_color,
                         stroke = average_point_stroke,
                         show.legend = F)  # 添加平均值点
}


# 分面标题----
p = p+  theme(
    strip.background = element_rect(fill = strip_background_color, 
                                    color = strip_background_border_color,
                                    linewidth = strip_background_border_size,
    ),
    strip.text = element_text(size = strip_text_size, 
                              face = strip_text_font_weight, 
                              color = strip_text_color),
    strip.placement = "outside",
    # strip.text = element_blank(),      # 隐藏标题文本
    # strip.background = element_blank() # 隐藏标题背景
)

if (!show_strip_text) {
    p = p + theme(strip.text = element_blank())  # 隐藏标题文本
} 
if (!show_strip_background) {
    p = p + theme(strip.background = element_blank())  # 隐藏标题背景
}



# 额外自定义的代码----
if (code_text != '') {
    print(code_text)
    eval(parse(text = code_text))
    
}

print(p)

ggsave(output_file, p, width = picture_width, height = picture_height, dpi = 500)



