#import "Basic";
#import "String";
#import "File";
#import "stb_image_write";

main :: ()
{
    builder: String_Builder;

    width := 255;
    height := 255;
    size := size_of(u32) * width * height;
    data: *u32 = alloc(size);
    head_ptr := data;
    print_to_builder(*builder, "P3\n");
    print_to_builder(*builder, "% %\n", width, height);
    print_to_builder(*builder, "255\n");
    for y : 0 .. height-1
    {
        for x : 0 .. width-1
        {
            r: u32 = 255;
            g: u32 = xx y;
            b: u32 = xx x;
            a: u32 = 255;
            // * Order is flipped RGBA -> ABGR
            << data = (a << 24) | (b << 16) | (g << 8) | r;
            data += 1;
            print_to_builder(*builder, "% % %\n", r, g, b);
        }
    }

    make_directory_if_it_does_not_exist("output");
    write_entire_file("output/image.ppm", *builder);
    stbi_write_png("output/image.png", xx width, xx height, 4, cast(*void)head_ptr, cast(s32)(size_of(u32) * width));
}