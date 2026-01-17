

get_palette_fun <- function(name = "gradient1") {
    name <- match.arg(name,
                      choices = paste0("gradient", 1:20))
    switch(name,
           gradient1  = colorRampPalette(c("#0000FF","#FFFFFF","#FF0000")),
           gradient2  = colorRampPalette(c("#81C7C1","#FFFFFF","#FC7956")),
           gradient3  = colorRampPalette(c("#FFFFFF","#FF6668")),
           gradient4  = colorRampPalette(c("#FF0000","#FFFF00","#008000")),
           gradient5  = colorRampPalette(c("#FF0000","#42F725")),
           gradient6  = colorRampPalette(c("#543005","#FFFFFF","#003C30")),
           gradient7  = colorRampPalette(c("#40004B","#FFFFFF","#00441B")),
           gradient8  = colorRampPalette(c("#8E0152","#FFFFFF","#276419")),
           gradient9  = colorRampPalette(c("#2D004B","#FFFFFF","#7F3B08")),
           gradient10 = colorRampPalette(c("#2D004B","#FFFFFF","#053061")),
           gradient11 = colorRampPalette(c("#A50026","#FAF8C0","#313695")),
           gradient12 = colorRampPalette(c("#A50026","#FAF8C0","#006837")),
           gradient13 = colorRampPalette(c("#F7FBFF",'#93C3DF','#4B97C9',"#08306B")),
           gradient14 = colorRampPalette(c("#F7FBFF",'#97D494',"#4DAF62",'#00441B')),
           gradient15 = colorRampPalette(c("#F7FBFF",'#FC8A6B',"#EF4533",'#67000D')),
           gradient16 = colorRampPalette(c("#FF4040","#A7D503","#18F472","#1872F4","#A703D5","#FE4B83")),
           gradient17 = colorRampPalette(c("#6E40AA","#FE4B83","#E2B72F","#52F667","#23ABD8","#A703D5")),
           gradient18 = colorRampPalette(c("#23171B","#2F9DF5","#4DF884","#DEDD32","#F65F18","#900C00")),
           gradient19 = colorRampPalette(c("#440154","#414487","#2A788E","#22A884","#7AD151","#FDE725")),
           gradient20 = colorRampPalette(c("#000004","#420A68","#932667","#DD513A","#FCFFA4","#FCFFA4")))
}


# myPalette <- get_palette_fun("gradient16")
# cols <- myPalette(7)          # 再生成 256 个颜色
