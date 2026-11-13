import AppKit
let out = CommandLine.arguments[1]
for (name, size) in [("Icon60@2x",120),("Icon60@3x",180),("Icon76@2x",152),("Icon83.5@2x",167),("Icon1024",1024)] {
    let n = CGFloat(size)
    let image = NSImage(size: NSSize(width:n,height:n))
    image.lockFocus()
    NSColor(calibratedRed:1,green:0.78,blue:0.08,alpha:1).setFill()
    NSBezierPath(rect:NSRect(x:0,y:0,width:n,height:n)).fill()
    let attributes: [NSAttributedString.Key: Any] = [.font:NSFont.boldSystemFont(ofSize:n * 0.43),.foregroundColor:NSColor.black]
    let text = "HG" as NSString
    let bounds = text.size(withAttributes:attributes)
    text.draw(at:NSPoint(x:(n-bounds.width)/2,y:(n-bounds.height)/2),withAttributes:attributes)
    image.unlockFocus()
    let bitmap = NSBitmapImageRep(data:image.tiffRepresentation!)!
    try bitmap.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:out+"/"+name+".png"))
}
