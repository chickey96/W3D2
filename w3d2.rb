require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database 
    include Singleton 

    def initialize 
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class User
    attr_accessor :id, :fname, :lname 

    def self.find_by_id(input_id)
        user = QuestionsDatabase.instance.execute(<<-SQL, input_id)
            SELECT 
                *
            FROM
                users
            WHERE
                id = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT
                *
            FROM
                users
            WHERE
                fname = ? AND lname = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_user_id(self.id)
    end
end

class Question 
    attr_accessor :id, :title, :body, :user_id 
    def self.find_by_author_id(input_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, input_id)
            SELECT
                *
            FROM
                questions
            WHERE
                user_id = ?
        SQL
        return nil unless questions.length > 0
        res = questions.map {|question| Question.new(question)}
        return res.first if res.length == 1
        res
    end

    def self.find_by_id(input_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, input_id)
            SELECT
                *
            FROM
                questions
            WHERE
                id = ?
        SQL
        return nil unless questions.length > 0
        Question.new(questions.first)
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def author
        User.find_by_id(self.user_id)
    end

    def replies 
        Reply.find_by_question_id(self.id)
    end
end

class Reply
    attr_accessor :id, :question_id, :parent_id, :user_id, :reply 
    def self.find_by_user_id(user_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT 
                *
            FROM
                replies
            WHERE
                user_id = ?
        SQL
        return nil if replies.empty?
        res = replies.map {|reply| Reply.new(reply)}
        return res.first if res.length == 1
        res
    end

    def self.find_by_id(input_id)
        reply = QuestionsDatabase.instance.execute(<<-SQL, input_id)
            SELECT 
                *
            FROM
                replies
            WHERE
                id = ?
        SQL
        return nil if reply.empty?
        Reply.new(reply.first)
    end

    def self.find_by_parent_id(parent_id)
        reply = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
            SELECT 
                *
            FROM
                replies
            WHERE
                parent_id = ?
        SQL
        return nil if reply.empty?
        Reply.new(reply.first)
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                question_id = ?
        SQL
        return nil if replies.empty?
        res = replies.map {|reply| Reply.new(reply)}
        return res.first if res.length == 1
        res
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @parent_id = options['parent_id']
        @user_id = options['user_id']
        @reply = options['reply']
    end

    def author 
        User.find_by_id(self.user_id)
    end

    def question 
        Question.find_by_id(self.question_id)
    end

    def parent_reply
        Reply.find_by_id(self.parent_id)
    end
    
    def child_replies
        Reply.find_by_parent_id(self.id)
    end
end

class QuestionFollow
    attr_accessor :id, :question_id, :user_id
    def self.followers_for_question_id(question_id)
        followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                users
            JOIN
                question_follows
            ON
                users.id = question_follows.user_id
            WHERE
                question_follows.question_id = ?
        SQL
        return nil if followers.empty?
        followers.map { |follower| User.new(follower) }
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end