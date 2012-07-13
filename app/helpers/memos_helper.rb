module MemosHelper
  # def format_column_value(memo, colname)
    # if colname == 'location' && memo.location.index('http://') == 0
      # link_to h(memo.location), memo.location
    # elsif colname == 'created_at'
      # memo.created_at.strftime '%Y-%m-%d %H:%M' if memo.created_at
    # else
      # h memo.send(colname)
    # end
  # end
  
  def format_column_value(ar, colname)
    if Memo === ar
      format_memo_column_value ar, colname
    elsif Attachment === ar
      format_attachment_column_value ar, colname
    end
  end
  
  def format_memo_column_value(memo, colname)
    if colname == 'location' && memo.location.index('http://') == 0
      link_to h(memo.location), memo.location
    elsif colname == 'created_at'
      memo.created_at.strftime '%Y-%m-%d %H:%M' if memo.created_at
    else
      h memo.send(colname)
    end
  end
  
  def format_attachment_column_value(atch, colname)
    if colname == 'content'
      # link_to h(atch.name), {:action => 'file', :id => atch.id, :filename => atch.name}
      if atch.content_type =~ /image\/(x-|p)?(jpe?g|png|gif)/
        image_tag url_for(:action => 'file', :id => atch.id, :filename => atch.name), :alt => h(atch.name)
      else
        link_to h(atch.name), {:action => 'file', :id => atch.id, :filename => atch.name}
      end
    else
      h atch.send(colname)
    end
  end
  
  def format_attachment(a)
    if a.content_type =~ /image\/(x-|p)?(jpe?g|png|gif)/
      "<span id=\"a#{a.id}\">#{link_to_function h(a.name), "$('a#{a.id}').innerHTML = '#{image_tag url_for(:action => 'file', :id => a.id, :filename => a.name), :alt => h(a.name)}'"}</span>"
    else
      link_to h(a.name), :action => 'file', :id => a.id, :filename => a.name
    end
  end
  
end
