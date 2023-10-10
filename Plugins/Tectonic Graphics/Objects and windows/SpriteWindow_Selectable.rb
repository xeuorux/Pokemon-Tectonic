class SpriteWindow_Selectable < SpriteWindow_Base
    def update
        super
        if self.active && @item_max > 0 && @index >= 0 && !@ignore_input
          if Input.repeat?(Input::UP)
            if @index >= @column_max ||
               (Input.trigger?(Input::UP) && (@item_max % @column_max)==0)
              oldindex = @index
              @index = (@index - @column_max + @item_max) % @item_max
              if @index!=oldindex
                pbPlayCursorSE()
                update_cursor_rect
              end
            end
          elsif Input.repeat?(Input::DOWN)
            if @index < @item_max - @column_max ||
               (Input.trigger?(Input::DOWN) && (@item_max % @column_max)==0)
              oldindex = @index
              @index = (@index + @column_max) % @item_max
              if @index!=oldindex
                pbPlayCursorSE()
                update_cursor_rect
              end
            end
          elsif Input.repeat?(Input::LEFT)
            if @column_max >= 2 && @index > 0
              oldindex = @index
              @index -= 1
              if @index!=oldindex
                pbPlayCursorSE()
                update_cursor_rect
              end
            end
          elsif Input.repeat?(Input::RIGHT)
            if @column_max >= 2 && @index < @item_max - 1
              oldindex = @index
              @index += 1
              if @index!=oldindex
                pbPlayCursorSE()
                update_cursor_rect
              end
            end
          elsif Input.repeat?(Input::JUMPUP)
            if @index > 0
              oldindex = @index
              if Input.press?(Input::CTRL)
                @index = 0
              else
                @index = [self.index-self.page_item_max, 0].max
              end
              if @index!=oldindex
                pbPlayCursorSE()
                self.top_row -= self.page_row_max
                update_cursor_rect
              end
            end
          elsif Input.repeat?(Input::JUMPDOWN)
            if @index < @item_max-1
              oldindex = @index
              if Input.press?(Input::CTRL)
                @index = @item_max-1
              else
                @index = [self.index+self.page_item_max, @item_max-1].min
              end
              if @index!=oldindex
                pbPlayCursorSE()
                self.top_row += self.page_row_max
                update_cursor_rect
              end
            end
          end
        end
      end
end