module DonationTransactionsHelper
    def pay_custom_frequency
        [
            ['One-time', 'ONE'],
            ['Weekly', 'WEEK'],
            ['Monthly', 'MONTH'],
            ['Yearly', 'YEAR']
        ]
    end
end
