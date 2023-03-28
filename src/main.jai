#import "Basic";
#import "String";
#import "File";
#import "stb_image_write";
#import "Random";
#import "Windows";
#import "Print_Color";
#import "Hash_Table";

#load "ui.jai";
#load "input.jai";
#load "ray.jai";
#load "math.jai";
#load "util.jai";
#load "opengl.jai";
#load "app.jai";

gen_color :: (r: Ray, world: *World) -> Vector3
{
    hit_rec: Hit_Record;
    if hit_any(world, r, FLOAT32_MAX, *hit_rec)
    {
        //* NOTE: simulate ray bouncing off surface and absorbing 50% light each bounce 
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
    SDL_Init(SDL_INIT_VIDEO);
    
    window: *SDL_Window;
	window = SDL_CreateWindow
	(
		"RayTracer", 
		SDL_WINDOWPOS_CENTERED,
		SDL_WINDOWPOS_CENTERED, 
		600, 600,
		SDL_WINDOW_OPENGL
	);

	if window == null 
	{
		print("Could not create window: %\n", to_string(SDL_GetError()));
		return;
	}

	print("%\n", to_string(ImGui.GetVersion()));
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
	gl_context := SDL_GL_CreateContext(window);
    if !gl_context 
	{
        print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        return;
    }

	gl_load(*gl, SDL_GL_GetProcAddress);

    imgui_context := ImGui.CreateContext();

    // Setup ImGui binding
    ImGui_ImplSdl_Init(window);

	ImGui.StyleColorsClassic();

	io := ImGui.GetIO();

	running := true;
	is_quit: bool;
	clear_color := make_vector4(0, 0, 0, 1.00);
	main_tool_active: bool;

    app_status := App_Status.Idle;

    builder: String_Builder;

    generation_settings: Generation_Data;
/*
    width := 200;
    height := 100;
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
    pixel := 0;
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

            current_progress_string := tprint("Processing %1%2\n", cast(int)((pixel / cast(float)(width*height)) * 100.0), "%%");
            print(current_progress_string);
            cursor_pos: COORD;
            cursor_pos.x = xx (current_progress_string.count - 2);
            clear_console_at_position(cursor_pos);
            pixel += 1;
        }
    }

    print_color("Processing completed.\n", color = .GREEN);
*/
    while running
	{
		reset_temporary_storage();
		reset_controller_input(*global_input.keyboard);

		event: SDL_Event;
        while SDL_PollEvent(*event) 
		{
            ImGui_ImplSdl_ProcessEvent(*event);
            if event.type == SDL_QUIT   is_quit = true;
            if event.type == SDL_WINDOWEVENT && 
			   event.window.event == SDL_WINDOWEVENT_CLOSE && 
			   event.window.windowID == SDL_GetWindowID(window) 
			{
				running = false;
            }

			if event.type ==
			{
				case SDL_KEYDOWN; #through;
				case SDL_KEYUP;
				{
					is_down: bool = event.key.state == SDL_PRESSED;
					was_down: bool;
					
					if event.key.state == SDL_RELEASED
					{
						was_down = true;
					}
					else if event.key.repeat != 0
					{
						was_down = true;
					}
					
					if event.key.repeat == 0
					{
						key := event.key.keysym.scancode;
						
						button_state := table_find_pointer(*global_input.keyboard.keys, key);
						if button_state 
						{
							process_keypress(button_state, is_down, was_down);
						}
						else
						{
							new_state: Button_State;
							process_keypress(*new_state, is_down, was_down);
							table_add(*global_input.keyboard.keys, key, new_state);
						}
					}
				}
			}
        }

		ImGui_ImplSdl_NewFrame(window);
		ImGui.NewFrame();

		is_new_file := false;
		is_open_file := false;
		is_save_file := false;
		
		ImGui.Begin("RayTracer", *main_tool_active, 
					IMGUI_WINDOW_FLAGS.NoTitleBar | 
					IMGUI_WINDOW_FLAGS.MenuBar |
					IMGUI_WINDOW_FLAGS.NoMove |
					IMGUI_WINDOW_FLAGS.NoResize |
					IMGUI_WINDOW_FLAGS.NoBackground);
		/* if ImGui.BeginMenuBar()
		{
			defer ImGui.EndMenuBar();
			if ImGui.BeginMenu("File")
			{
				defer ImGui.EndMenu();
				is_new_file = ImGui.MenuItem("New", "Ctrl+N");

				is_open_file = ImGui.MenuItem("Open..", "Ctrl+O");

				is_save_file = ImGui.MenuItem("Save", "Ctrl+S");

				if ImGui.MenuItem("Save as..") 
				{
					
				}
			}
		}
        */

        if app_status == .Generating
        {
            using generation_settings;
            ImGui.Text("Generating... %/%", current_pixel, width * height);
            for x : 0 .. width-1
            {
                color: Vector3;
                for 0 .. n_samples-1
                {
                    u: float = (x + random_get_zero_to_one_open()) / cast(float)width;
                    v: float = (current_y + random_get_zero_to_one_open()) / cast(float)height;

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
                << image_data_ptr = (a << 24) | (b << 16) | (g << 8) | r;
                image_data_ptr += 1;
                current_pixel += 1;
            }
            current_y -= 1;
            gl_update_texture(image_data, image_texture, width, height);

            if current_y < 0 
            {
                app_status = .Ok;
            }
        }

        if app_status == .Generating || app_status == .Ok
        {
            using generation_settings;
            ImGui.Image(cast(*void)image_texture, make_ImVec2(xx width, xx height));
            
            if app_status == .Ok
            {
                if ImGui.Button("Regenerate")
                {
                    if image_data
                    {
                        image_data_ptr = null;
                        free(image_data);
                        glDeleteTextures(1, *image_texture);
                    }
                    current_pixel = 0;
                    app_status = .Idle;
                }
            }   
        }

        if app_status == .Idle then update_generation_settings(*generation_settings);

        if app_status == .Idle
        {
            if ImGui.Button("Generate")
            {
                if is_generation_settings_valid(*generation_settings)
                {
                    using generation_settings;  
                    size_to_allocate := size_of(u32) * width * height;
                    image_data = alloc(size_to_allocate);
                    memset(image_data, 0, size_to_allocate);
                    image_data_ptr = image_data;

                    camera.lower_left_corner = make_vector3(-2, -1, -1);
                    camera.right = make_vector3(4, 0, 0);
                    camera.up = make_vector3(0, 2, 0);

                    n_samples = 100;
                    current_y = xx (height-1);

                    image_texture = gl_create_texture_from_data(image_data, width, height);

                    app_status = .Generating;
                }
            }
        }

		ImGui.End();

		ImGui.Render();
        glViewport(0, 0, xx io.DisplaySize.x, xx io.DisplaySize.y);
        glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        SDL_GL_SwapWindow(window);
	}

    // make_directory_if_it_does_not_exist("output");
    // write_entire_file("output/image.ppm", *builder);
    // stbi_write_png("output/image.png", xx width, xx height, 4, cast(*void)head_ptr, cast(s32)(size_of(u32) * width));
}