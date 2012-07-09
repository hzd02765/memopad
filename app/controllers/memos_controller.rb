require 'net/pop'

class MemosController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @memo_pages, @memos = paginate :memos, :per_page => 10, :order => 'created_at desc'
  end

  def show
    @memo = Memo.find(params[:id])
  end

  def new
    @memo = Memo.new
  end

  def create
    @memo = Memo.new(params[:memo])
    if file_attached?
      attach_file
    end
    if @memo.save
      flash[:notice] = _('Memo was successfully created.')
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @memo = Memo.find(params[:id])
  end

  def update
    @memo = Memo.find(params[:id])
    if file_attached?
      attach_file
    end
    if @memo.update_attributes(params[:memo])
      flash[:notice] = _('Memo was successfully updated.')
      redirect_to :action => 'show', :id => @memo
    else
      render :action => 'edit'
    end
  end

  def destroy
    Memo.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def file
    attachment = Attachment.find params[:id]
    filename = (params[:fileext]) ? "#{params[:filename]}.#{params[:fileext]}" : params[:filename]
    if filename != attachment.name
      render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404, :layout => true
    else
      send_data attachment.content, :filename => attachment.name, :type => attachment.content_type, :disposition => 'inline'
    end
  end
  
  def mail
    memos = []
    Net::POP3.APOP(MemoPad::USE_APOP).start(MemoPad::POP_SERVER[:address], MemoPad::POP_SERVER[:port],
											MemoPad::POP_SERVER[:account], MemoPad::POP_SERVER[:password]) do |pop|
      unless pop.mails.empty?
        pop.each_mail do |m|
          # m.delete if MemoMailer.receive m.pop
          memo = MemoMailer.receive m.pop
          if memo
            m.delete
            memos << memo
          end
        end
      end
    end
    
    # redirect_to :action => 'list'
    
    memos.sort! do |a, b|
      a.created_at <=> b.created_at
    end
    render :partial => 'item', :collection => memos
  end

  private
  
  def file_attached?
    params[:file] && params[:file].respond_to?(:original_filename)
  end
  
  def attach_file
    @memo.attachments.create :name => params[:file].original_filename,
        :size => params[:file].length, :content_type => params[:file].content_type,
        :content => params[:file].read
  end
end
