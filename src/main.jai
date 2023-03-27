#import "Basic";
#import "String";
#import "File";
#import "stb_image_write";
#import "Random";

#load "ray.jai";
#load "math.jai";

gen_color :: (r: Ray, world: *World) -> Vector3
{
    hit_rec: Hit_Record;
    if hit_any(world, r, FLOAT32_MAX, *hit_rec)
    {
        target := hit_rec.p + hit_rec.normal + random_in_unit_sphere();
        new_ray: Ray;
        new_ray.origin = hit_rec.p;
        new_ray.direction = target - hit_rec.p;
        return 0.5*gen_color(new_ray, world);
    }
    else
    {
        dir := normalize(r.direction);
        t := 0.5*(dir.y + 1);
        return (1.0-t) * make_vector3(1, 1, 1) + t*make_vector3(0.5, 0.7, 1.0);
    }
}

main :: ()
{
    builder: String_Builder;

    width := 400;
    height := 200;
    size := size_of(u32) * width * height;
    data: *u32 = alloc(size);
    head_ptr := data;
    n_samples := 100;

    camera: Camera;
    camera.lower_left_corner = make_vector3(-2, -1, -1);
    camera.right = make_vector3(4, 0, 0);
    camera.up = make_vector3(0, 2, 0);

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
            color: Vector3;
            for 0 .. n_samples-1
            {
                u: float = (x + random_get_zero_to_one_open()) / cast(float)width;
                v: float = (y + random_get_zero_to_one_open()) / cast(float)height;

                ray := get_ray(camera, u, v);
                color += gen_color(ray, *world);
            }
            color /= cast(float)n_samples;
            color = make_vector3(sqrt(color.x), sqrt(color.y), sqrt(color.z));

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