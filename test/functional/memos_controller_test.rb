require File.dirname(__FILE__) + '/../test_helper'
require 'memos_controller'

# Re-raise errors caught by the controller.
class MemosController; def rescue_action(e) raise e end; end

class MemosControllerTest < Test::Unit::TestCase
  fixtures :memos
  fixtures :attachments

  ANCHOR_OFFSET = 2
  
  def setup
    @controller = MemosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = memos(:one).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:memos)
    assert_select 'a[href=http://example.com/3]', 'http://example.com/3'
    assert_select 'a[href=http://example.com/5]', 'http://example.com/5'
    assert_select 'a', {:text => /http:\/\/example.com\/\d/, :count => 2}
    
    assert_select 'td', {:text => /2007-09-25 15:32/, :count => 1}
    
    assert_select 'td', {:text => memos(:one).attachments.length, :count => 1}
    assert_select 'td', {:text => memos(:two).attachments.length, :count => 1}
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:memo)
    assert assigns(:memo).valid?
    
    # assert_select 'a', :count => 2
    assert_select 'a', {:count => ANCHOR_OFFSET + 2}
    
    assert_select 'p', {:text => /#{memos (:one).location}/, :count => 1}
    assert_select 'p', {:text => /2007-09-25 15:32/, :count => 1}
    
    assert_select 'a[href=/memos/file/1/hello.txt]', {:text => 'hello.txt', :count => 1}
    assert_select 'a[href=/memos/file/3/change.txt]', {:text => 'change.txt', :count => 1}
  end

  def test_file
    get :file, :id => attachments(:two).id, :filename => attachments(:two).name
    assert_response :success
    assert_equal attachments(:two).content_type, @response.content_type
    assert_equal attachments(:two).content, @response.body
    fn = attachments(:two).name.split '.'
    get :file, :id => attachments(:two).id, :filename => fn[0], :fileext => fn[1]
    assert_response :success
    assert_equal attachments(:two).content_type, @response.content_type
    assert_equal attachments(:two).content, @response.body
  end
  
  def test_mail
    Net::POP3.new('memotest') do |addr, port, acct, pwd|
      assert_equal MemoPad::POP_SERVER[:address], addr
      assert_equal MemoPad::POP_SERVER[:port], port
      assert_equal MemoPad::POP_SERVER[:account], acct
      assert_equal MemoPad::POP_SERVER[:password], pwd
    end
    
    get :mail
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    assert !Net::POP3.instance.mails[0].deleted?
    assert Net::POP3.instance.mails[1].deleted?
  end
  
  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:memo)
  end

  def test_create
    num_memos = Memo.count

    post :create, :memo => {:text => 'テストデータ#3', :location => 'テスト'}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_memos + 1, Memo.count
  end
  
  def test_create_with_file
    file = ActionController::TestUploadedFile.new("#{RAILS_ROOT}/README", 'text/plain')
    num_memos = Memo.count
    post :create, :memo => {:text => 'file upload test', :location => 'テスト'}, :file => file
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    assert_equal num_memos + 1, Memo.count
    assert_not_nil assigns(:memo)
    assert !assigns(:memo).attachments.empty?
    assert_equal 'README', assigns(:memo).attachments[0].name
    assert_equal 'text/plain', assigns(:memo).attachments[0].content_type
    assert_equal IO.read("#{RAILS_ROOT}/README"), assigns(:memo).files[0].content
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:memo)
    assert assigns(:memo).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Memo.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Memo.find(@first_id)
    }
  end
  
  def test_show_bookmark
    get :show, :id => memos(:three).id
    
    assert_response :success
    assert_select 'a[href=http://example.com/3]', 'http://example.com/3'
    # assert_select 'a', :count => 3
    assert_select 'a', {:count => ANCHOR_OFFSET + 1}
  end
  
  def test_update_add_file
    file = ActionController::TestUploadedFile.new("#{RAILS_ROOT}/README", 'text/plain')
    post :update, :id => @first_id, :file => file
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
    assert_not_nil assigns(:memo)
    
    check_attachment assigns(:memo), 3
    
    # assert_equal 3, assigns(:memo).attachments.length
    # assert_equal 'README', assigns(:memo).attachments[2].name
    # assert_equal 'text/plain', assigns(:memo).attachments[2].content_type
    # assert_equal IO.read("#{RAILS_ROOT}/README"), assigns(:memo).files[2].content
  end
  
  def test_update_new_file
    file = ActionController::TestUploadedFile.new("#{RAILS_ROOT}/README", 'text/plain')
    post :update, :id => memos(:three).id, :file => file
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => memos(:three).id
    assert_not_nil assigns(:memo)
    
    check_attachment assigns(:memo), 1
    
    # assert_equal 1, assigns(:memo).attachments.length
    # assert_equal 'README', assigns(:memo).attachments[0].name
    # assert_equal 'text/plain', assigns(:memo).attachments[0].content_type
    # assert_equal IO.read("#{RAILS_ROOT}/README"), assigns(:memo).files[0].content
  end
  
  def check_attachment(memo, count)
    assert_equal count, memo.attachments.length
    assert_equal 'README', memo.attachments[count - 1].name
    assert_equal 'text/plain', memo.attachments[count - 1].content_type
    assert_equal IO.read("#{RAILS_ROOT}/README"), memo.files[count - 1].content
  end
end
