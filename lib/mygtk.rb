require "mygtk/version"
require 'gtk2'

module MyGtk
  W = Gtk::Window.new
  class Tool < Gtk::Window
    def initialize
      @window = W
      @drawable = W.window
      @gc = Gdk::GC.new(@drawable)
      @colormap = Gdk::Colormap.system
      @color = Gdk::Color.new(0, 0, 0)
      @fontdesc = Pango::FontDescription.new
    end
    attr_reader :window
    
    def color(r, g, b)
      @color = Gdk::Color.new(r, g, b)
      @colormap.alloc_color(@color, false, true)
      @color
    end
    
    def rectangle(fill, x, y, width, height, color = nil)
      set_color(color)
      @drawable.draw_rectangle(@gc, fill, x, y, width, height)
    end
    
    def arc(fill, x, y, width, height, d1, d2, color = nil)
      set_color(color)
      @drawable.draw_arc(@gc, fill, x, y, width, height, d1, d2)
    end
    
    def point(x, y, color = nil)
      set_color(color)
      @drawable.draw_point(@gc, x, y)
    end
    
    def line(x1, y1, x2, y2, color = nil)
      set_color(color)
      @drawable.draw_lines(@gc, [[x1, y1], [x2, y2]])
    end
    
    def lines(array, color = nil)
      set_color(color)
      @drawable.draw_lines(@gc, array)
    end
    
    def polygon(fill, array, color = nil)
      set_color(color)
      @drawable.draw_polygon(@gc, fill, array)
    end
    
    def text(str, x, y, size, color = nil)
      set_color(color)
      @fontdesc.set_size(size)
      layout = Pango::Layout.new(W.pango_context)
      layout.font_description = @fontdesc
      layout.text = str
      @drawable.draw_layout(@gc, x, y, layout)
    end
    
    def set_color(color)
      @color = color if color
      @gc.set_foreground(@color)
    end
    private :set_color
    
    def load_pic(filename)
      GdkPixbuf::Pixbuf.new(file: filename)
    end
    
    def save_pic(img, filename, type = "png")
      img.save(filename, type)
    end
    
    def show_pic(img, x, y)
      @drawable.draw_pixbuf(@gc, img, 0, 0, x, y, img.width, img.height, Gdk::RGB::DITHER_NONE, 0, 0)
    end
    
    def get_pic(x, y, width, height)
      GdkPixbuf::Pixbuf.from_drawable(nil, @drawable, x, y, width, height)
    end
  end
  
  class Event < Tool
    def initialize
      super
    end
    
    def draw(&bk)
      W.signal_connect("expose_event", &bk)
    end
    
    def timer(interval, &bk)
      Gtk.timeout_add(interval, &bk)
    end
    
    def key_in(&bk)
      W.signal_connect("key_press_event", &bk)
    end
    
    def mouse_button(&bk)
      W.add_events(Gdk::Event::BUTTON_PRESS_MASK)
      W.signal_connect("button_press_event", &bk)
    end
    
    def make_window(&bk)
      w = Gtk::Window.new
      w.instance_eval(&bk)
      w.show_all
      w
    end
    
    def button(&bk)
      b = Gtk::Button.new
      b.instance_eval(&bk)
      b
    end
  end
  
  def self.app(width: 300, height: 300, title: "oekaki", &bk)
    W.title = title
    W.set_size_request(width, height)
    W.set_app_paintable(true)
    W.realize
    
    Event.new.instance_eval(&bk)
    
    W.signal_connect("destroy") {Gtk.main_quit}
    W.show
    Gtk.main
  end
end
