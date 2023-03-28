App_Status :: enum u32
{
    Idle;
    Generating;
    Ok;
    Error;
}

Generation_Data :: struct 
{
    width: u32;
    height: u32;

    current_x: s32;
    current_y: s32;
    current_pixel: u32;

    n_samples: u32;

    camera: Camera;

    sphere_setting: Sphere;
    selected_sphere: s32;

    world: World;

    image_data: *u32;
    image_data_ptr: *u32;

    image_texture: u32;
}

is_generation_settings_valid :: (using settings: *Generation_Data) -> bool
{
    return width > 0 && height > 0;
}

update_generation_settings :: (using settings: *Generation_Data)
{
    //* Image settings
    ImGui.Text("Image Settings");
    ImGui.PushItemWidth(100);
    ImGui.InputScalar("Width##image_settings", DType.U32, *settings.width);
    ImGui.InputScalar("Height##image_settings", DType.U32, *settings.height);
    ImGui.Separator();
    ImGui.PopItemWidth();

    //* World settings
    ImGui.Text("World Settings");
    ImGui.NewLine();
    ImGui.Text("Add sphere");
    ImGui.PushItemWidth(200);
    ImGui.InputFloat3("Position##sphere_settings", *sphere_setting.center.component);
    ImGui.InputFloat("Radius##sphere_settings", *sphere_setting.radius);
    ImGui.PopItemWidth();
    if ImGui.Button("Add##sphere_settings")
    {
        add_sphere(*world, sphere_setting.center, sphere_setting.radius);
    }

    //* Sphere data display
    ImGui.Text("Spheres List");
    ImGui.PushItemWidth(150);
    if ImGui.BeginListBox("##spheres")
    {
        defer ImGui.EndListBox();

        for world.spheres
        {
            sphere_text := tprint("Sphere #%", it_index + 1);
            is_selected := selected_sphere == it_index;
            if ImGui.Selectable(temp_c_string(sphere_text), is_selected)
                selected_sphere = xx it_index;

            if is_selected
                ImGui.SetItemDefaultFocus();
        }
    }
    ImGui.PopItemWidth();
    if selected_sphere >= 0 && world.spheres.count > 0
    {
        ImGui.SameLine();
        ImGui.BeginChild("Sphere_List", .{0, 150}, false, IMGUI_WINDOW_FLAGS.HorizontalScrollbar);
        ImGui.InputFloat3("Position##selected_sphere", *world.spheres[selected_sphere].center.component);
        ImGui.InputFloat("Radius##selected_sphere", *world.spheres[selected_sphere].radius);
        if ImGui.Button("Remove##selected_sphere")
        {
            array_ordered_remove_by_index(*world.spheres, selected_sphere);
            selected_sphere = 0;
        }
        ImGui.EndChild();
    }
    ImGui.Separator();
    
}