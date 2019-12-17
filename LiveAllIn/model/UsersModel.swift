class UsersModel {
    var email = ""
    var plan_name: [String] = []
    
    init(email:String,plan_name: [String] ) {
        self.email = email
        self.plan_name = plan_name
    }
}
