#TODO this class should be broken up
class MenuHelper
  include Rubygame

  def initialize(screen, layer,text_helper, sections, cursor_x, cursor_y, cursor_main_color=:blue, cursor_inactive_color=:white)
    @layer = layer
    @text_rendering_helper = text_helper
    @cursor = Surface.new([cursor_x, cursor_y])
    @cursor_main_color = cursor_main_color
    @cursor_inactive_color = cursor_inactive_color
    @cursor.fill(@cursor_inactive_color)
    @screen = screen
    reset_indices
    replace_sections(sections)
  end

  def current_menu_entries
    @text_lines
  end

  def current_selected_menu_entry_name
    if @show_section
      if subsection_active?(@section_position)
        if @needs_option
          active_subsection.option_at(@option_position).name
        else
          active_subsection.info[@subsection_position].name
        end
        
      else
        active_section.content[@section_position].text
      end
    else
      @text_lines[@cursor_position]
    end
  end


  def color_for_current_section_cursor
    @cursor_main_color
  end

  def active_section
    @menu_sections[@cursor_position]
  end

  def move_cursor_down
    move_cursor(1)
  end

  def clamping_delta(value, maxsize, delta=1)
    (value + delta) % maxsize
  end

  def size_or_one(target)
    target.size
    #target.respond_to?(:size) ? target.size : 1
  end

  def move_cursor(dir)
    if @show_section
       if subsection_active?(@section_position)
         if @needs_option
           puts "moving at option layer: #{@option_position} of #{size_or_one(active_option)}"
           @option_position = clamping_delta(@option_position, size_or_one(active_option), dir)
         else
           puts "moving at subsection layer"
          @subsection_position = clamping_delta(@subsection_position, size_or_one(active_subsection), dir)
         end
      else
        puts "moving at section layer"
        @section_position = clamping_delta(@section_position, size_or_one(active_section.content), dir)
       end
    else
      puts "moving at top layer"
      @cursor_position = clamping_delta(@cursor_position, size_or_one(@text_lines), dir)
    end
  end

  def move_cursor_up
    move_cursor(-1)
  end
  def enter_current_cursor_location(game)
    if @show_section
      if subsection_active?(@section_position)
        if @needs_option
          puts "activating at option layer"
          active_subsection.activate(@cursor_position, game, @section_position, @subsection_position, @option_position)
        else
          puts "activating at subsection layer"
          @needs_option = active_subsection.activate(@cursor_position, game, @section_position, @subsection_position)
        end

      else
        puts "activating at section layer"
        active_subsection.activate(@cursor_position, game, @section_position)
      end

    else
      puts "showing section in lieu of activation at top layer"
      @show_section = true
    end

  end
  def cancel_action
    if @needs_option
      @needs_option = false
    end
    if subsection_active?(@section_position)
      @active_position = nil
      return
    end
    if @show_section
      @show_section = false
      @section_position = 0
      return
    end

    reset_indices
  end
  def replace_sections(sections)
    @menu_sections = sections
    @text_lines = @menu_sections.collect{|ms|ms.text}
  end
  #TODO this is odd to have in the api for this class... reconsider
  def render_text_to_layer(text, conf)
    @text_rendering_helper.render_lines_to_layer( text, conf)
  end
  def render_text_to(surface, text, conf)
    @text_rendering_helper.render_lines_to(surface, text, conf)
  end
  def active_subsection
    active_section.content_at(@section_position)
  end
  def active_option
    active_subsection.option_at(@option_position)
  end

  def draw(menu_layer_config, game)
    render_text_to_layer( @text_lines, menu_layer_config.main_menu_text)
    @cursor.fill(color_for_current_section_cursor)
    if @show_section
      render_text_to_layer(active_section.text_contents, menu_layer_config.section_menu_text)
      conf = menu_layer_config.in_section_cursor

      if subsection_active?(@section_position)
        surf = active_subsection.details
        conf = menu_layer_config.in_subsection_cursor

        surf.blit(@layer, menu_layer_config.details_inset_on_layer) if surf
        @cursor.fill(:black)

        if @needs_option
          conf = menu_layer_config.in_option_section_cursor
          optsurf = active_subsection.surface_for(@subsection_position)
          optsurf.blit(@layer, menu_layer_config.options_inset_on_layer) if optsurf
          @cursor.blit(@layer, conf.cursor_offsets_at(@option_position, game, active_subsection))
        else
          @cursor.blit(@layer, conf.cursor_offsets_at(@subsection_position, game, active_subsection))
        end
      else
        @cursor.blit(@layer, conf.cursor_offsets_at(@section_position, game, active_subsection))
      end
    else

      conf = menu_layer_config.main_cursor
#      puts "top level: #{active_section}"
      @cursor.blit(@layer, conf.cursor_offsets_at(@cursor_position, game, active_section))
    end
    @layer.blit(@screen, menu_layer_config.layer_inset_on_screen)
  end

  def subsection_active?(position)
    (@active_position == position) && !@active_position.nil?
  end
  def set_active_subsection(position)
    puts "activated with #{position}"
    @active_position = position
  end

  def reset_indices
    @active_position = nil
    @cursor_position = 0
    @section_position = 0
    @option_position = 0
    @subsection_position = 0
    @show_section = false
    @needs_option = false
  end
end
