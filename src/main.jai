#import "Basic";
#import "String";
#import "File";
#import "stb_image_write";

#load "ray.jai";

gen_color :: (r: Ray, world: *World) -> Vector3
{
    hit_rec: Hit_Record;
    if hit_any(world, r, FLOAT32_MAX, *hit_rec)
    {
        n := hit_rec.normal;
        return 0.5*make_vector3(n.x+1, n.y+1, n.z+1);
    }
    dir := normalize(r.direction);
    t := 0.5*(dir.y + 1);
    return (1.0-t) * make_vector3(1, 1, 1) + t*make_vector3(0.5, 0.7, 1.0);
}

main :: ()
{
    builder: String_Builder;

    width := 200;
    height := 100;
    size := size_of(u32) * width * height;
    data: *u32 = alloc(size);
    head_ptr := data;

    lower_left_corner := make_vector3(-2, -1, -1);
    horizontal := make_vector3(4, 0, 0);
    vertical := make_vector3(0, 2, 0);
    origin := Vector3.{};

    world: World;
    add_sphere(*world, .{0, 0, -1}, 0.5);
    add_sphere(*world, .{0, -100.5, -1}, 100);

    print_to_builder(*builder, "P3\n");
    print_to_builder(*builder, "% %\n", width, height);
    print_to_builder(*builder, "255\n");
    for < y : height-1 .. 0
    {
        for x : 0 .. width-1
        {
            u: float = cast(float) x / width;
            v: float = cast(float) y / xx height; 

            ray: Ray;
            ray.origin = origin;
            ray.direction = lower_left_corner + u*horizontal + v*vertical;
            color := gen_color(ray, *world);

            r: u32 = xx (color.x * 255.99);
            g: u32 = xx (color.y * 255.99);
            b: u32 = xx (color.z * 255.99);
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