from PIL import Image,ImageDraw,ImageFont

# sample text and font
def draw_kana(kana):

    unicode_text = kana 
    arial_font = ImageFont.truetype("/Library/Fonts/Arial Unicode.ttf", 600, encoding='unic') 
    
    # get the line size
    text_width, text_height = arial_font.getsize(unicode_text)
    
    # create a blank canvas with extra space between lines
    canvas = Image.new('RGB', (text_width, text_height), (255, 255, 255))
    
    # draw the text onto the text canvas, and use black as the text color
    draw = ImageDraw.Draw(canvas)
    draw.text((5,5), unicode_text, font = arial_font, fill = "#000000")
    
    # save the blank canvas to a file
    canvas.save("%s.png"%unicode_text, "PNG")

kanas = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
for kana in kanas:
    draw_kana(kana) 
# for kana_unic in range(0x3041, 0x3190):
#     try:
#         draw_kana(kana_unic)
#     except: 
#         continue
# 
