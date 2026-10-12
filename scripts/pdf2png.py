"""pdf2png.py <deck.pdf> [--sheet] — 每页渲染成 PNG；--sheet 另拼一张缩略图总览。"""
import sys
import pymupdf as fitz   # pip install pymupdf
pdf = sys.argv[1]; base = pdf[:-4]; doc = fitz.open(pdf); paths = []
for i, pg in enumerate(doc, 1):
    p = f'{base}-{i:02d}.png'; pg.get_pixmap(dpi=110).save(p); paths.append(p)
if '--sheet' in sys.argv:
    cols, w = 4, 400; h = int(w * 5.625 / 10); rows = (len(doc) + cols - 1) // cols
    sheet = fitz.open(); page = sheet.new_page(width=cols * w, height=rows * (h + 18))
    for k, pg in enumerate(doc):
        r, c = divmod(k, cols); x, y = c * w, r * (h + 18)
        page.show_pdf_page(fitz.Rect(x + 4, y + 16, x + w - 4, y + h + 14), doc, k)
        page.insert_text((x + 6, y + 12), str(k + 1), fontsize=11)
    sheet[0].get_pixmap(dpi=72).save(f'{base}-sheet.png'); print(f'{base}-sheet.png')
print(len(paths), 'pages')
