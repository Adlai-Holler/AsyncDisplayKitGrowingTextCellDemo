
#import "ViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface TestCellNode: ASCellNode <ASEditableTextNodeDelegate>
@property (nonatomic, strong) ASEditableTextNode *textNode;

// this will get called when our height may have changed
@property (nonatomic, strong) dispatch_block_t invalidate;
@property (nonatomic) BOOL shouldInvalidateAfterLayout;
@end
@implementation TestCellNode

- (instancetype)init {
	self = [super init];
	if (!self) { return nil; }
	self.textNode = [ASEditableTextNode new];
	self.textNode.attributedText = [[NSAttributedString alloc] initWithString:@"Hello world. Welcome to \"will it grow?\""];
	[self addSubnode:self.textNode];
	self.textNode.delegate = self;
	return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
	return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) child:self.textNode];
}

- (void)editableTextNodeDidUpdateText:(ASEditableTextNode *)editableTextNode {
//	NOTE: Uncommenting this breaks everything, which is unexpected
//	[self invalidateCalculatedLayout];
	[self setNeedsLayout];
	self.invalidate();
}

@end
@interface ViewController () <ASTableViewDataSource, ASTableViewDelegate>
@property (nonatomic, strong) ASEditableTextNode *textNode;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	ASTableView *tableView = [[ASTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 568) style:UITableViewStylePlain asyncDataFetching:YES];
	tableView.asyncDataSource = self;
	tableView.asyncDelegate = self;
	[self.view addSubview:tableView];
	tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (ASCellNode *)tableView:(ASTableView *)tableView nodeForRowAtIndexPath:(NSIndexPath *)indexPath {
	TestCellNode *node = [TestCellNode new];
	__weak ASTableView *weakTableView = tableView;
	node.invalidate = ^() {
		[NSOperationQueue.mainQueue addOperationWithBlock:^{
			[weakTableView beginUpdates];
			[weakTableView endUpdatesAnimated:NO completion:nil];
		}];
	};
	return node;
}


@end
